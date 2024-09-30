# frozen_string_literal: true
module FiscalYear
  def self.last_day_of_fiscal_quarter(fiscal_year, fiscal_quarter)
    year = fiscal_quarter == 1 ? fiscal_year - 1 : fiscal_year
    month = case fiscal_quarter
            when 1
              12
            when 2
              3
            when 3
              6
            else
              9
            end
    Date.new(year, month, -1)
  end

  def self.last_fiscal_year
    today = Date.today
    current_fiscal_year = today.month <= 9 ? today.year : today.year + 1
    current_fiscal_year - 1
  end
end
