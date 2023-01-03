module UploadCsv
  def self.import(csv_string)
    report = {}
    conn = ApplicationRecord.connection

    ApplicationRecord.transaction do
      conn.execute <<~SQL
        create temporary table _csv_appointment (
          doctor_last_name text not null,
          doctor_first_name text not null,
          national_provider_identifier text not null,
          patient_last_name text not null,
          patient_first_name text not null,
          universal_patient_identifier text not null,
          start_time timestamptz not null,
          end_time timestamptz not null
        ) on commit drop;
      SQL

      conn.raw_connection.copy_data('copy _csv_appointment from stdin with (format csv, header true)') do
        conn.raw_connection.put_copy_data(csv_string)
      end

      report[:people] = conn.execute <<~SQL
        insert into people (first_name, last_name, created_at, updated_at)
        select doctor_first_name,
               doctor_last_name, NOW(), NOW()
        from _csv_appointment
        union
        select patient_first_name,
               patient_last_name, NOW(), NOW()
        from _csv_appointment
        ON CONFLICT DO NOTHING;
      SQL

      report[:patients] = conn.execute <<~SQL
        insert into patients (upi, person_id, created_at, updated_at)
        select distinct LOWER(universal_patient_identifier), id, NOW(), NOW()
        from _csv_appointment csv
        inner join people p on p.first_name = csv.patient_first_name and p.last_name = csv.patient_last_name
        ON CONFLICT DO NOTHING;
      SQL

      report[:doctors] = conn.execute <<~SQL
        insert into doctors (npi, person_id, created_at, updated_at)
        select distinct national_provider_identifier, id, NOW(), NOW()
        from _csv_appointment csv
        inner join people p on p.first_name = csv.doctor_first_name and p.last_name = csv.doctor_last_name
        ON CONFLICT DO NOTHING;
      SQL

      report[:appointments] = conn.execute <<~SQL
        alter table _csv_appointment add column timerange tstzrange;
        create index on _csv_appointment (timerange);
        update _csv_appointment set timerange = tstzrange(start_time, end_time);

        with _new_appointments (patient_id, doctor_id, status, timerange) as (
          select
            patients.person_id,
            doctors.person_id,
            case
              when patients.person_id = doctors.person_id
                or timerange && range_agg(timerange) OVER doctor_appointments
                or timerange && range_agg(timerange) OVER patient_appointments
              then 'error'
              else 'ok'
            end::enum_status_appointment,
            csv.timerange
          from _csv_appointment csv
          inner join patients on lower(csv.universal_patient_identifier) = patients.upi
          inner join doctors on csv.national_provider_identifier = doctors.npi
          window doctor_appointments as (
            partition by national_provider_identifier
            order by timerange
            range between unbounded preceding and unbounded following exclude current row
          ), patient_appointments as (
            partition by universal_patient_identifier
            order by timerange
            range between unbounded preceding and unbounded following exclude current row
          )
        )
        insert into appointments (patient_id, doctor_id, status, timerange, created_at, updated_at)
        select
          csv.patient_id,
          csv.doctor_id,
          case
            when csv.status = 'error'
              or count(p.id) > 0
              or count(d.id) > 0
            then 'error'
            else 'ok'
          end::enum_status_appointment,
          csv.timerange,
          now(), now()
        from _new_appointments csv
        left outer join appointments p
          on csv.patient_id = p.patient_id
         and csv.timerange && p.timerange
         and p.status = 'ok'
        left outer join appointments d
          on csv.doctor_id = d.doctor_id
         and csv.timerange && d.timerange
         and d.status = 'ok'
        group by csv.patient_id, csv.doctor_id, csv.timerange, csv.status
        on conflict do nothing
        returning *
      SQL
    end
    report
  end
end
