#!/usr/bin/env ruby

require 'date'
require 'icalendar'

### Create iCal ics file with multiple events
class EventCreator
  OFF = Hash.new

  # October
  OFF[Date.new(2019, 10, 11)] = true
  OFF[Date.new(2019, 10, 14)] = true
  OFF[Date.new(2019, 10, 16)] = true

  # November
  OFF[Date.new(2019, 11, 11)] = true
  OFF[Date.new(2019, 11, 28)] = true
  OFF[Date.new(2019, 11, 29)] = true

  # December
  OFF[Date.new(2019, 12, 23)] = true
  OFF[Date.new(2019, 12, 24)] = true
  OFF[Date.new(2019, 12, 25)] = true
  OFF[Date.new(2019, 12, 26)] = true
  OFF[Date.new(2019, 12, 27)] = true
  OFF[Date.new(2019, 12, 30)] = true
  OFF[Date.new(2019, 12, 31)] = true

  # January
  OFF[Date.new(2020, 1, 1)] = true
  OFF[Date.new(2020, 1, 2)] = true
  OFF[Date.new(2020, 1, 3)] = true
  OFF[Date.new(2020, 1, 20)] = true

  # February
  OFF[Date.new(2020, 2, 17)] = true
  OFF[Date.new(2020, 2, 18)] = true

  # March
  OFF[Date.new(2020, 3, 30)] = true
  OFF[Date.new(2020, 3, 31)] = true

  # April
  OFF[Date.new(2020, 4, 1)] = true
  OFF[Date.new(2020, 4, 2)] = true
  OFF[Date.new(2020, 4, 3)] = true

  # May
  OFF[Date.new(2020, 5, 25)] = true

  attr_reader :cal

  def initialize(first, last)
    @cal = Icalendar::Calendar.new
    make_events(first, last)
  end

  def make_events(first, last)
    count = 1

    first.upto(last) do |date|
      if (OFF[date] == true)
        next
      end
      if (date.wday > 0 && date.wday < 6)
        e = Icalendar::Event.new
        e.dtstart = date
        e.summary = "#{(count % 2 == 1) ? 'A' : 'B'} Day"
        @cal.add_event(e)
        count += 1
      end
    end
  end

  def to_ics
    File.open("scripted.ics", "w") { |f| f.write @cal.to_ical }
  end
end

if __FILE__ == $0
  first_day = Date.parse(ARGV[0])
  last_day = Date.parse(ARGV[1])
  calendar = EventCreator.new(first_day, last_day)
  calendar.to_ics
end
