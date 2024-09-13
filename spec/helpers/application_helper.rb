require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#current_fiscal_year_and_quarter" do
    context "when the current date is before October 1st" do
      it "returns the correct fiscal year and quarter for First Day of the Fiscal Year" do
        fiscal_year, fiscal_quarter = helper.fiscal_year_and_quarter(Date.parse("2023-10-01")).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2024)
        expect(fiscal_quarter).to eq(1)
      end

      it "returns the correct fiscal year and quarter for Last Day of the Fiscal Year" do
        fiscal_year, fiscal_quarter = helper.fiscal_year_and_quarter(Date.parse("2023-09-30")).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2023)
        expect(fiscal_quarter).to eq(4)
      end

      it "returns the correct fiscal year and quarter for Q2 2026" do
        fiscal_year, fiscal_quarter = helper.fiscal_year_and_quarter(Date.parse("2026-01-01")).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2026)
        expect(fiscal_quarter).to eq(2)
      end

      it "returns the correct fiscal year and quarter for Q3 2030" do
        fiscal_year, fiscal_quarter = helper.fiscal_year_and_quarter(Date.parse("2030-04-20")).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2030)
        expect(fiscal_quarter).to eq(3)
      end

      it "returns the correct fiscal year and quarter for Q4 2031" do
        fiscal_year, fiscal_quarter = helper.fiscal_year_and_quarter(Date.parse("2031-08-20")).values_at(:year, :quarter)
        expect(fiscal_year).to eq(2031)
        expect(fiscal_quarter).to eq(4)
      end
    end
  end
end
