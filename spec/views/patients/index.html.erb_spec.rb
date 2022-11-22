require 'rails_helper'

RSpec.describe "patients/index", type: :view do
  before(:each) do
    assign(:patients, [
      Patient.create!(
        upi: "Upi",
        person: "Person",
        doctor: "Doctor"
      ),
      Patient.create!(
        upi: "Upi",
        person: "Person",
        doctor: "Doctor"
      )
    ])
  end

  it "renders a list of patients" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Upi".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Person".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Doctor".to_s), count: 2
  end
end
