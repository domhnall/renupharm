module WorkingDays
  WORKDAYS = [1,2,3,4,5,6]

  def self.end_of_next_working_day_plus_one(from_date)
    end_of_next_working_day(end_of_next_working_day(from_date))
  end

  def self.end_of_next_working_day(from_date)
    next_day = self.next_working_day(from_date)
    DateTime.new(next_day.year, next_day.month, next_day.day, 17, 30, 00)
  end

  def self.next_working_day(from_date)
    test_date = from_date.to_datetime + 1.day
    WORKDAYS.include?(test_date.wday) ? test_date : next_business_day(test_date)
  end
end
