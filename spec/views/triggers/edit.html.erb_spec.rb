require 'rails_helper'

RSpec.describe "triggers/edit", type: :view do
  before(:each) do
    @trigger = assign(:trigger, Trigger.create!(
      :touchpoint_id => 1,
      :name => "MyString",
      :kind => "MyString",
      :fingerprint => "MyString"
    ))
  end

  it "renders the edit trigger form" do
    render

    assert_select "form[action=?][method=?]", trigger_path(@trigger), "post" do

      assert_select "input[name=?]", "trigger[touchpoint_id]"

      assert_select "input[name=?]", "trigger[name]"

      assert_select "input[name=?]", "trigger[kind]"

      assert_select "input[name=?]", "trigger[fingerprint]"
    end
  end
end
