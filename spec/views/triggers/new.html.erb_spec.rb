require 'rails_helper'

RSpec.describe "triggers/new", type: :view do
  before(:each) do
    assign(:trigger, Trigger.new(
      :touchpoint_id => 1,
      :name => "MyString",
      :kind => "MyString",
      :fingerprint => "MyString"
    ))
  end

  it "renders new trigger form" do
    render

    assert_select "form[action=?][method=?]", triggers_path, "post" do

      assert_select "input[name=?]", "trigger[touchpoint_id]"

      assert_select "input[name=?]", "trigger[name]"

      assert_select "input[name=?]", "trigger[kind]"

      assert_select "input[name=?]", "trigger[fingerprint]"
    end
  end
end
