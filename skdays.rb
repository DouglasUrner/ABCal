#!/usr/bin/env ruby

require 'date'
require 'icalendar'

### Create iCal ics file with multiple events
class EventCreator
  OFF = {}

  attr_reader :cal

  def initialize(first, last, file)
    @cal = Icalendar::Calendar.new
    # RFC 7986
    @cal.append_custom_property("NAME", "SKHS Days")
    @cal.append_custom_property("REFRESH-INTERVAL;VALUE=DURATION", "P1H")
    # Interim values
    @cal.append_custom_property("X-WR-CALNAME", "SKHS Days")
    @cal.append_custom_property("X-PUBLISHED-TTL;VALUE=DURATION", "P1H")
    File.open(file, 'r') do |f|
      f.each_line do |l|
        OFF[Date.parse(l)] = true
      end
    end
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
        e.dtstart = Icalendar::Values::Date.new(date)
        e.summary = "#{(count % 2 == 1) ? 'A' : 'B'} Day"
        @cal.add_event(e)
        count += 1
      end
    end
  end

  def to_ics
    File.open("docs/skdays.ics", "w") { |f| f.write @cal.to_ical }
  end
end

if __FILE__ == $0
  require 'optparse'

  opts = {}

  OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on("-f DATE")     { |v| opts[:first_day] = Date.parse(v) }
    o.on("-F FILENAME") { |v| opts[:filename]  = v }
    o.on("-l DATE")     { |v| opts[:last_day]  = Date.parse(v) }
    o.on("-h")          { puts o; exit }
    o.on("-v")          { |v| opts[:verbose] = v }

  end.parse!

  if (opts[:verbose] == true) then puts opts; end

  calendar = EventCreator.new(opts[:first_day], opts[:last_day], opts[:filename])
  calendar.to_ics
end
