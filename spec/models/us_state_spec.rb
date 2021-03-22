require 'rails_helper'

RSpec.describe UsState, type: :model do
  describe "STATES" do
    it "is an array" do
      expect(UsState::STATES.class).to eq(Array)
    end

    it "of 51 elements" do
      expect(UsState::STATES.size).to eq(51)
    end

    it "each element is a hash with name and abbreviation" do
      expect(UsState::STATES.first.class).to eq(Hash)
      expect(UsState::STATES.first.keys).to match_array([:name, :abbreviation])
    end
  end
end
