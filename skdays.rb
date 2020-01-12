#!/usr/bin/env ruby

require 'date'
require 'icalendar'

### Create iCal ics file with multiple events
class EventCreator
  attr_reader :cal

  OFF = {}
  
  def initialize(opts)
    @cal = Icalendar::Calendar.new
    # RFC 7986
    @cal.append_custom_property("NAME", opts[:cal_name])
    @cal.append_custom_property("DESCRIPTION", opts[:desc])
    @cal.append_custom_property("REFRESH-INTERVAL;VALUE=DURATION", opts[:ttl])
    # Interim values
    @cal.append_custom_property("X-WR-CALNAME", opts[:cal_name])
    @cal.append_custom_property("X-WR-CALDESC", opts[:desc])
    @cal.append_custom_property("X-PUBLISHED-TTL;VALUE=DURATION", opts[:ttl])
    File.open(opts[:off_file], 'r') do |f|
      f.each_line do |l|
        OFF[Date.parse(l)] = true
      end
    end
    add_events(opts)
  end

  def add_events(opts)
    count = 1

    opts[:first_day].upto(opts[:last_day]) do |date|
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

  def to_ics(out_file)
    File.open(out_file, "w") { |f| f.write @cal.to_ical }
  end
end

if __FILE__ == $0
  require 'optparse'

  # Defaults
  opts = {
    cal_name: "SKHS Days",
    desc: "South Kitsap High School A/B day calendar (with snow days).",
    out_file: "docs/skdays.ics",
    ttl: "P1H"
  }

  OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on("-f DATE")     { |v| opts[:first_day] = Date.parse(v) }
    o.on("-I FILENAME") { |v| opts[:off_file]  = v }
    o.on("-l DATE")     { |v| opts[:last_day]  = Date.parse(v) }
    o.on("-O FILENAME") { |v| opts[:out_file]  = v }
    o.on("-h")          { puts o; exit }
    o.on("-v")          { |v| opts[:verbose] = v }

  end.parse!

  if (opts[:verbose] == true) then puts opts; end

  # TODO: validate opts before calling

  calendar = EventCreator.new(opts)
  calendar.to_ics(opts[:out_file])
end
