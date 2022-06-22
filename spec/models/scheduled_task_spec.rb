# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduledTask, type: :model do
  describe 'validate helper ' do
    it 'determines next business day from Monday is Tuesday' do
      dt = ScheduledTask.skip_weekends(Date.parse('13-01-2020'))
      expect(dt.wday).to eq(2)
    end

    it 'determines next business day from Friday is Monday' do
      dt = ScheduledTask.skip_weekends(Date.parse('17-01-2020'))
      expect(dt.wday).to eq(1)
    end
  end

  describe 'validate query' do
    it 'finds expired touchpoints with valid sql' do
      forms = ScheduledTask.check_expiring_forms
      expect(forms.size).to be >= 0
    end
  end
end
