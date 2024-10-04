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
