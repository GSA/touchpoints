require 'rails_helper'

require 'utilities/fiscal_year'

describe FiscalYear do
  include ActiveSupport::Testing::TimeHelpers

  it 'computes the last fiscal year in quarter 1' do
    travel_to Date.new(2022, 1, 15) do
      expect(FiscalYear.last_fiscal_year).to eq(2021)
    end
  end

  it 'computes the last fiscal year in quarter 2' do
    travel_to Date.new(2022, 5, 6) do
      expect(FiscalYear.last_fiscal_year).to eq(2021)
    end
  end

  it 'computes the last fiscal year in quarter 3' do
    travel_to Date.new(2022, 9, 30) do
      expect(FiscalYear.last_fiscal_year).to eq(2021)
    end
  end

  it 'computes the last fiscal year in quarter 4' do
    travel_to Date.new(2022, 11, 30) do
      expect(FiscalYear.last_fiscal_year).to eq(2022)
    end
  end

  it 'computes the last day of a given fiscal year and quarter' do
    expect(FiscalYear.last_day_of_fiscal_quarter(2022, 2)).to eq(Date.new(2022, 3, 31))
    expect(FiscalYear.last_day_of_fiscal_quarter(2025, 4)).to eq(Date.new(2025, 9, 30))
    expect(FiscalYear.last_day_of_fiscal_quarter(2019, 1)).to eq(Date.new(2018, 12, 31))
    expect(FiscalYear.last_day_of_fiscal_quarter(2022, 3)).to eq(Date.new(2022, 6, 30))
  end
end
