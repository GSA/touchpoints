require 'rails_helper'

RSpec.describe "triggers/index", type: :view do
  before(:each) do
    assign(:triggers, [
      Trigger.create!(
        :touchpoint_id => 2,
        :name => "Name",
        :kind => "Kind",
        :fingerprint => "Fingerprint"
      ),
      Trigger.create!(
        :touchpoint_id => 2,
        :name => "Name",
        :kind => "Kind",
        :fingerprint => "Fingerprint"
      )
    ])
  end

  it "renders a list of triggers" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Kind".to_s, :count => 2
    assert_select "tr>td", :text => "Fingerprint".to_s, :count => 2
  end
end
