require 'rails_helper'

describe AppointmentsController do
  {
    '#index' => {
      'lists appointmes' => {
        request: %i[get appointments_path],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -1 }],
          patient: [{ person_id: -2 }],
          appointment: [{ doctor_id: -1, patient_id: -2,
                          start_date: '2022-05-16 18:43:11 UTC',
                          end_date: '2022-05-16 19:43:11 UTC',
                          timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
        },
        expect: {
          status: 200,
          html: {
            ['.table tbody td:nth-child(1)', :text] => ['Alice Alfalfa'],
            ['.table tbody td:nth-child(2)', :text] => ['Bob Barker'],
            ['.table tbody td:nth-child(3)', :text] => ['2022-05-16 18:43:11 UTC'.to_datetime.to_formatted_s(:long)],
            ['.table tbody td:nth-child(4)', :text] => ['2022-05-16 19:43:11 UTC'.to_datetime.to_formatted_s(:long)]
          }
        }
      }
    },
    '#create' => {
      'successfully creates an appointment record' => {
        request: %i[post appointments_path],
        params: { appointment: { start_date: '2022-05-16 18:43:11 UTC', end_date: '2022-05-16 19:43:11 UTC',
                                 patient_id: -1, doctor_id: -2 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui' }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui' }],
            Appointment => [{ doctor_id: -2, patient_id: -1, status: 'ok',
                              timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
          }
        }
      },
      'does not create a appointment record' => {
        request: %i[post appointments_path],
        params: { appointment: { start_date: '2022-05-16 18:43:11 UTC', end_date: '2022-05-16 19:43:11 UTC',
                                 patient_id: -1, doctor_id: nil } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          patient: [{ person_id: -1, upi: '1234567890azertyui' }]
        },
        expect: {
          status: 422,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui' }],
            Appointment => []
          }
        }
      }
    },
    '#show' => {
      'successfully show a appointment record' => {
        request: [:get, :appointment_path, { id: -1 }],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -1 }],
          patient: [{ person_id: -2 }],
          appointment: [{ id: -1, doctor_id: -1, patient_id: -2,
                          start_date: '2022-05-16 18:43:11 UTC',
                          end_date: '2022-05-16 19:43:11 UTC',
                          timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
        },
        expect: {
          status: 200,
          html: {
            ['span[data-name=start_time]', :text] => ['2022-05-16 18:43:11 UTC'.to_datetime.to_formatted_s(:long)],
            ['span[data-name=end_time]', :text] => ['2022-05-16 19:43:11 UTC'.to_datetime.to_formatted_s(:long)],
            ['h5[data-name=doctor_full_name] .link-primary', :text] => ['Alice Alfalfa'],
            ['h5[data-name=patient_full_name] .link-primary', :text] => ['Bob Barker']
          }
        }
      },
      'does not show an appointment record' => {
        request: [:get, :appointment_path, { id: -3 }],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -1 }],
          patient: [{ person_id: -2 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1 }],
            Patient => [{ person_id: -2 }]
          }
        }
      }
    },
    '#update' => {
      'successfully updates an appointment record' => {
        request: [:put, :appointment_path, { id: -1 }],
        params: { appointment: { id: -1, start_date: '2022-05-16 18:43:11 UTC', end_date: '2022-05-16 20:43:11 UTC',
                                 patient_id: -2, doctor_id: -1 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -1 }],
          patient: [{ person_id: -2 }],
          appointment: [{ id: -1, doctor_id: -1, patient_id: -2,
                          start_date: '2022-05-16 18:43:11 UTC',
                          end_date: '2022-05-16 19:43:11 UTC',
                          timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1 }],
            Patient => [{ person_id: -2 }],
            Appointment => [{ doctor_id: -1, patient_id: -2, status: 'ok',
                              timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 20:43:11 UTC'.to_datetime }]
          }
        }
      },
      'does not update an appointment record' => {
        request: [:put, :appointment_path, { id: -1 }],
        params: { appointment: { id: -1, start_date: nil, end_date: '2022-05-16 19:43:11 UTC',
                                 patient_id: -2, doctor_id: -1 } },
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -1 }],
          patient: [{ person_id: -2 }],
          appointment: [{ id: -1, doctor_id: -1, patient_id: -2,
                          start_date: '2022-05-16 18:43:11 UTC',
                          end_date: '2022-05-16 19:43:11 UTC',
                          timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
        },
        expect: {
          status: 422,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1 }],
            Patient => [{ person_id: -2 }],
            Appointment => [{ id: -1, doctor_id: -1, patient_id: -2, status: 'ok',
                              timerange: '2022-05-16 18:43:11 UTC'.to_datetime...'2022-05-16 19:43:11 UTC'.to_datetime }]
          }
        }
      }
    },
    '#delete' => {
      'successfully deletes an appointment record' => {
        request: [:delete, :appointment_path, { id: -1 }],
        db: {
          appointment: [{ id: -1, start_date: '2022-05-16 18:43:11 UTC', end_date: '2022-05-16 20:43:11 UTC' }]
        },
        expect: {
          status: 302,
          db: {
            Appointment => []
          }
        }
      },
      'does not delete an appointment record' => {
        request: [:delete, :appointment_path, { id: -9 }],
        db: {
          appointment: [{ id: -1, start_date: '2022-05-16 18:43:11 UTC', end_date: '2022-05-16 20:43:11 UTC' }]
        },
        expect: {
          status: 302,
          db: {
            Appointment => [{ id: -1 }]
          }
        }
      }
    }
  }.each do |action, h|
    describe action do
      h.each do |desc, spec|
        it desc do
          spec[:db].each do |type, records|
            records.each do |attrs|
              FactoryBot.create(type, **attrs)
            end
          end
          method, *url_args = spec[:request]
          public_send(method, public_send(*url_args), params: spec[:params])

          spec.dig(:expect, :db)&.each do |ar_class, expected_records|
            expected = expected_records.map { |el| hash_including(el.with_indifferent_access) }
            expect(ar_class.all.map(&:attributes)).to match_array(expected)
          end
          html = Nokogiri::HTML.parse(response.body)
          spec.dig(:expect, :html)&.each do |(selector, meth), expected_values|
            expect(html.css(selector).map { |el| el.public_send(meth) }).to match(expected_values)
          end

          expect(response.status).to eq(spec.dig(:expect, :status))
        end
      end
    end
  end
end
