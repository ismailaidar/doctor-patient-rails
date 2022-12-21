require 'rails_helper'

describe PatientsController do
  {
    '#index' => {
      'lists patients' => {
        request: %i[get patients_path],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          patient: [
            { person_id: -1, upi: '1234567890azertyui' },
            { person_id: -2, upi: '0234567891azertyui' }
          ]
        },
        expect: {
          status: 200,
          html: {
            ['.table tbody td:nth-child(2)', :text] => %w[Alice Bob],
            ['.table tbody td:nth-child(3)', :text] => %w[Alfalfa Barker]
          }
        }
      }
    },
    '#create' => {
      'successfully creates a patient record' => {
        request: %i[post patients_path],
        params: { patient: { upi: '1234567890azertyui', person_id: -1, doctor_id: -2 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui' }]
          }
        }
      },

      'does not create a patient record with a malformed npi' => {
        request: %i[post patients_path],
        params: { patient: { upi: '1234567890azertyu', person_id: -1, doctor_id: -2 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }]
        },
        expect: {
          status: 422,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => []
          }
        }
      }
    },
    '#show' => {
      'successfully show a patient record' => {
        request: [:get, :patient_path, { id: -1 }],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
        },
        expect: {
          status: 200,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
          },
          html: {
            ['span[data-name=first_name]', :text] => ['Alice'],
            ['span[data-name=last_name]', :text] => ['Alfalfa'],
            ['span[data-name=upi]', :text] => ['1234567890azertyui'],
            ['span[data-name=doctor_full_name]', :text] => ['Bob Barker']
          }
        }
      },
      'does not show a patient record' => {
        request: [:get, :patient_path, { id: -99 }],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
          }

        }
      }
    },
    '#update' => {
      'successfully updates a patient record' => {
        request: [:put, :patient_path, { id: -1 }],
        params: { patient: { upi: '1234567890azemmmmm', person_id: -1, doctor_id: -2 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567891', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567891', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azemmmmm', doctor_id: -2 }]
          }
        }
      },
      'does not update a patient record' => {
        request: [:put, :patient_path, { id: -1 }],
        params: { patient: { upi: '12', person_id: -1, doctor_id: -2 } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567890', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
        },
        expect: {
          status: 422,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567890', status: 'active' }],
            Patient => [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }]
          }
        }
      }
    },
    '#delete' => {
      'successfully deletes a patient record' => {
        request: [:delete, :patient_path, { id: -1 }],
        db: {
          person: [{ id: -1 }],
          patient: [{ person_id: -1, upi: '1234567890azertyui' }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }],
            Patient => []
          }
        }
      },
      "successfully deletes a patient record and it's related appointments" => {
        request: [:delete, :patient_path, { id: -1 }],
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567890', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }],
          appointment: [{ doctor_id: -2, patient_id: -1 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567890' }],
            Patient => [],
            Appointment => []
          }
        }
      }, 'does not delete a patient record' => {
        request: [:delete, :patient_path, { id: -3 }],
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -2, npi: '1234567890', status: 'active' }],
          patient: [{ person_id: -1, upi: '1234567890azertyui', doctor_id: -2 }],
          appointment: [{ doctor_id: -2, patient_id: -1 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -2, npi: '1234567890' }],
            Patient => [{ person_id: -1 }],
            Appointment => [{ doctor_id: -2, patient_id: -1 }]
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
