require 'rails_helper'

RSpec.describe "triggers/show", type: :view do
  before(:each) do
    @trigger = assign(:trigger, Trigger.create!(
      :touchpoint_id => 2,
      :name => "Name",
      :kind => "Kind",
      :fingerprint => "Fingerprint"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Kind/)
    expect(rendered).to match(/Fingerprint/)
  end
end
