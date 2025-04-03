require 'rails_helper'

describe FiscalYear do
  include ActiveSupport::Testing::TimeHelpers

  describe '#fiscal_quarter_dates' do
    context 'when the current date is before October 1st' do
      it 'returns the start and end dates for Q2 2025' do
        start_and_end_dates = FiscalYear.fiscal_quarter_dates(2025, 2)
        expect(start_and_end_dates[:start_date]).to eq(Date.parse("2025-01-01").beginning_of_day)
        expect(start_and_end_dates[:end_date]).to eq(Date.parse("2025-03-31").end_of_day)
      end

      it 'returns the start and end dates for Q3 2026' do
        start_and_end_dates = FiscalYear.fiscal_quarter_dates(2026, 3)
        expect(start_and_end_dates[:start_date]).to eq(Date.parse("2026-04-01").beginning_of_day)
        expect(start_and_end_dates[:end_date]).to eq(Date.parse("2026-06-30").end_of_day)
      end

      it 'returns the start and end dates for Q4 2027' do
        start_and_end_dates = FiscalYear.fiscal_quarter_dates(2027, 4)
        expect(start_and_end_dates[:start_date]).to eq(Date.parse("2027-07-01").beginning_of_day)
        expect(start_and_end_dates[:end_date]).to eq(Date.parse("2027-09-30").end_of_day)
      end

      it 'returns the start and end dates for Q1 2028' do
        start_and_end_dates = FiscalYear.fiscal_quarter_dates(2028, 1)
        expect(start_and_end_dates[:start_date]).to eq(Date.parse("2027-10-01").beginning_of_day)
        expect(start_and_end_dates[:end_date]).to eq(Date.parse("2027-12-31").end_of_day)
      end
    end
  end

  describe '#fiscal_year_and_quarter' do
    context 'when the current date is before October 1st' do
      it 'returns the correct fiscal year and quarter for First Day of the Fiscal Year' do
        fiscal_year, fiscal_quarter = FiscalYear.fiscal_year_and_quarter(Date.parse('2023-10-01')).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2024)
        expect(fiscal_quarter).to eq(1)
      end

      it 'returns the correct fiscal year and quarter for Last Day of the Fiscal Year' do
        fiscal_year, fiscal_quarter = FiscalYear.fiscal_year_and_quarter(Date.parse('2023-09-30')).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2023)
        expect(fiscal_quarter).to eq(4)
      end

      it 'returns the correct fiscal year and quarter for Q2 2026' do
        fiscal_year, fiscal_quarter = FiscalYear.fiscal_year_and_quarter(Date.parse('2026-01-01')).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2026)
        expect(fiscal_quarter).to eq(2)
      end

      it 'returns the correct fiscal year and quarter for Q3 2030' do
        fiscal_year, fiscal_quarter = FiscalYear.fiscal_year_and_quarter(Date.parse('2030-04-20')).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2030)
        expect(fiscal_quarter).to eq(3)
      end

      it 'returns the correct fiscal year and quarter for Q4 2031' do
        fiscal_year, fiscal_quarter = FiscalYear.fiscal_year_and_quarter(Date.parse('2031-08-20')).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2031)
        expect(fiscal_quarter).to eq(4)
      end
    end
  end

  describe '#last_fiscal_year' do
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
  end

  describe '#last_day_of_fiscal_quarter' do
    it 'computes the last day of a given fiscal year and quarter' do
      expect(FiscalYear.last_day_of_fiscal_quarter(2022, 2)).to eq(Date.new(2022, 3, 31))
      expect(FiscalYear.last_day_of_fiscal_quarter(2025, 4)).to eq(Date.new(2025, 9, 30))
      expect(FiscalYear.last_day_of_fiscal_quarter(2019, 1)).to eq(Date.new(2018, 12, 31))
      expect(FiscalYear.last_day_of_fiscal_quarter(2022, 3)).to eq(Date.new(2022, 6, 30))
    end
  end
end
