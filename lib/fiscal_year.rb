module FiscalYear
  def self.first_day_of_fiscal_quarter(date)
    # Adjust the month to align with the fiscal year starting in October
    fiscal_month = (date.month - 10) % 12 + 1
    fiscal_quarter = ((fiscal_month - 1) / 3) + 1

    # Calculate the first month of the fiscal quarter
    fiscal_start_month = ((fiscal_quarter - 1) * 3 + 10) % 12
    fiscal_start_month = 12 if fiscal_start_month == 0 # Handle December correctly

    # Determine the fiscal year for the quarter
    fiscal_year = date.year
    fiscal_year -= 1 if date.month < 10

    # Return the first day of the quarter
    Date.new(fiscal_year, fiscal_start_month, 1)
  end

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

  def self.fiscal_year_and_quarter(date)
    fiscal_year = date.year

    # Adjust fiscal year upward if the current month is October or later
    fiscal_year += 1 if date.month >= 10

    if [1, 2, 3].include?(date.month)
      fiscal_quarter = 2
    elsif [4, 5, 6].include?(date.month)
      fiscal_quarter = 3
    elsif [7, 8, 9].include?(date.month)
      fiscal_quarter = 4
    elsif [10, 11, 12].include?(date.month)
      fiscal_quarter = 1
    end

    {
      year: fiscal_year,
      quarter: fiscal_quarter,
    }
  end
end
