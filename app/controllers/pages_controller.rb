class PagesController < ApplicationController
  def index
    @last_doctors = Doctor.includes(:person).last(5)
    @unassigned_people = Person.joins('LEFT OUTER JOIN doctors
      ON doctors.person_id = people.id
      LEFT OUTER JOIN patients
      ON patients.person_id = people.id
      ').where('doctors.person_id IS null AND patients.person_id IS null').last(5)
  end
end
