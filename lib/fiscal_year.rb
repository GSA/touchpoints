module FiscalYear
  def self.fiscal_quarter_dates(fiscal_year, fiscal_quarter)
    start_date, end_date = case fiscal_quarter
      when 1 then [Date.new(fiscal_year - 1, 10, 1), Date.new(fiscal_year - 1, 12, 31)] # Q1: Oct - Dec of the prior calendar year relativ to the fiscal year
      when 2 then [Date.new(fiscal_year, 1, 1), Date.new(fiscal_year, 3, 31)]  # Q2: Jan - Mar
      when 3 then [Date.new(fiscal_year, 4, 1), Date.new(fiscal_year, 6, 30)]  # Q3: Apr - Jun
      when 4 then [Date.new(fiscal_year, 7, 1), Date.new(fiscal_year, 9, 30)]  # Q4: Jul - Sep
      else
        raise ArgumentError, "Invalid quarter: #{fiscal_quarter}. Must be 1, 2, 3, or 4."
      end

    {
      start_date: start_date.beginning_of_day,
      end_date: end_date.end_of_day
    }
  end

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
