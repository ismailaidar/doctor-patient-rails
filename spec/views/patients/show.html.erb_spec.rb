require 'rails_helper'

RSpec.describe "patients/show", type: :view do
  before(:each) do
    assign(:patient, Patient.create!(
      upi: "Upi",
      person: "Person",
      doctor: "Doctor"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Upi/)
    expect(rendered).to match(/Person/)
    expect(rendered).to match(/Doctor/)
  end
end
