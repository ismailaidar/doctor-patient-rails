require 'rails_helper'

describe DoctorsController do
  {
    '#index' => {
      'lists doctors' => {
        request: %i[get doctors_path],
        db: {
          person: [
            { id: -1, first_name: 'Alice', last_name: 'Alfalfa' },
            { id: -2, first_name: 'Bob',   last_name: 'Barker' }
          ],
          doctor: [
            { person_id: -1, npi: '1234567890' },
            { person_id: -2, npi: '9999999999' }
          ]
        },
        expect: {
          status: 200
        }
      }
    },
    '#create' => {
      'successfully creates a doctor record' => {
        request: %i[post doctors_path],
        params: { doctor: { npi: '1234567890', person_id: -1 } },
        db: {
          person: [{ id: -1 }, { id: -2 }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1, npi: '1234567890', status: 'active' }]
          }
        }
      },

      'does not create a doctor record with a malformed npi' => {
        request: %i[post doctors_path],
        params: { doctor: { npi: '123456789', person_id: -1 } },
        db: {
          person: [{ id: -1 }]
        },
        expect: {
          status: 422,
          db: {
            Person => [{ id: -1 }],
            Doctor => []
          }
        }
      }
    },
    '#update' => {
      'successfully updates a doctor record' => {
        request: [:put, :doctor_path, { id: -1 }],
        params: { doctor: { npi: '1234567890', person_id: -1, status: 'active' } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -1, npi: '1234567890', status: 'active' }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1, npi: '1234567890', status: 'active' }]
          }
        }
      },
      'does not update a doctor record' => {
        request: [:put, :doctor_path, { id: -1 }],
        params: { doctor: { npi: '123456789', person_id: -1, status: 'active' } },
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -1, npi: '1234567890', status: 'active' }]
        },
        expect: {
          status: 422,
          raise_error: ActiveRecord::ActiveRecordError,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1, npi: '1234567890', status: 'active' }]
          }
        }
      }
    },
    '#delete' => {
      'successfully deletes a doctor record' => {
        request: [:delete, :doctor_path, { id: -1 }],
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -1, npi: '1234567890', status: 'active' }]
        },
        expect: {
          status: 302,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => []
          }
        }
      },
      'does not delete a doctor record' => {
        request: [:delete, :doctor_path, { id: -1 }],
        db: {
          person: [{ id: -1 }, { id: -2 }],
          doctor: [{ person_id: -1, npi: '1234567890', status: 'active' }],
          patient: [{ person_id: -2, upi: '1234567890azertyui', doctor_id: -1 }],
          appointment: [{ doctor_id: -1, patient_id: -2, timerange: '[2022-11-11T09:32, 2022-11-11T10:32)' }]
        },
        expect: {
          status: 302,
          raise_error: ActiveRecord::ActiveRecordError,
          db: {
            Person => [{ id: -1 }, { id: -2 }],
            Doctor => [{ person_id: -1, npi: '1234567890' }]
          }
        }
      }
    }
  }.each do |action, h|
    describe action do
      h.each do |desc, spec|
        it desc do
          # Create necessary records
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

          spec.dig(:expect, :html)&.each do |(selector, meth), expected_values|
            expect(html.css(selector).map { |el| el.public_send(meth) }).to match(expected_values)
          end

          expect(response.status).to eq(spec.dig(:expect, :status))
        end
      end
    end
  end
end
