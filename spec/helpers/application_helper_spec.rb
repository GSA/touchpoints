require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_submission_time" do
    let(:time_zone) { "Eastern Time (US & Canada)" }

    it "returns time for today's submissions" do
      travel_to Time.zone.local(2025, 2, 17, 14, 30) do
        datetime = Time.zone.now
        expect(helper.format_submission_time(datetime, time_zone)).to eq(datetime.in_time_zone(time_zone).strftime("%-I:%M %p"))
      end
    end

    it "returns month and day for submissions from this year (but not today)" do
      datetime = Time.zone.now.beginning_of_year + 5.days
      expect(helper.format_submission_time(datetime, time_zone)).to eq(datetime.in_time_zone(time_zone).strftime("%b %e"))
    end

    it "returns MM/DD/YYYY for submissions from last calendar year" do
      datetime = 1.year.ago.beginning_of_year + 10.days
      expect(helper.format_submission_time(datetime, time_zone)).to eq(datetime.in_time_zone(time_zone).strftime("%m/%d/%Y"))
    end

    it "returns MM/DD/YYYY for submissions older than last year" do
      datetime = 2.years.ago
      expect(helper.format_submission_time(datetime, time_zone)).to eq(datetime.in_time_zone(time_zone).strftime("%m/%d/%Y"))
    end
  end
end
