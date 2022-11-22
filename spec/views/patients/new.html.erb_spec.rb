require 'rails_helper'

RSpec.describe "patients/new", type: :view do
  before(:each) do
    assign(:patient, Patient.new(
      upi: "MyString",
      person: "MyString",
      doctor: "MyString"
    ))
  end

  it "renders new patient form" do
    render

    assert_select "form[action=?][method=?]", patients_path, "post" do

      assert_select "input[name=?]", "patient[upi]"

      assert_select "input[name=?]", "patient[person]"

      assert_select "input[name=?]", "patient[doctor]"
    end
  end
end
