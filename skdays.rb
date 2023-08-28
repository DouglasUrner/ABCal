#!/usr/bin/env ruby

require 'date'
require 'icalendar'

### Create iCal ics file with multiple events
class EventCreator
  attr_reader :cal

  OFF = {}

  def initialize(opts)
    @extend_year = 0 # Number of days to add to :last_day (e.g., for snow days).
    @cal = Icalendar::Calendar.new

    # RFC 7986
    @cal.append_custom_property("NAME", opts[:cal_name])
    @cal.append_custom_property("DESCRIPTION", opts[:desc])
    @cal.append_custom_property("REFRESH-INTERVAL;VALUE=DURATION", opts[:ttl])

    # Interim values
    @cal.append_custom_property("X-WR-CALNAME", opts[:cal_name])
    @cal.append_custom_property("X-WR-CALDESC", opts[:desc])
    @cal.append_custom_property("X-PUBLISHED-TTL;VALUE=DURATION", opts[:ttl])

    # Scan off_file to find X entries, and, if they are not set on the command line,
    # search for F and L entries to set :first_day and :last_day.

    File.open(opts[:off_file], 'r') do |f|
      f.each_line do |l|
        # Clean up records.
        l.strip!
        r = Array.new(l.split(/\|\s*/))

        exception = { reason: r[1], message: r[2] }
        case (exception[:reason])
        when 'F'
          # Set first day (if not set on the commandline).
          if (opts[:first_day] == nil)
            opts[:first_day] = Date.parse(r[0])
            if (opts[:verbose] == true)
              puts "Set opts[:first_day] to #{opts[:first_day]}."
            end
          else
            if (opts[:verbose] == true)
              puts "Ignored 'F': opts[:first_day] set to #{opts[:first_day]} on commandline."
            end
          end
          next
        when 'L'
          # Set last day (if not set on the commandline).
          if (opts[:last_day] == nil)
            opts[:last_day] = Date.parse(r[0])
            if (opts[:verbose] == true)
              puts "Set opts[:last_day] to #{opts[:last_day]}."
            end
          else
            if (opts[:verbose] == true)
              puts "Ignored 'L': opts[:last_day] set to #{opts[:last_day]} on commandline."
            end
          end
          next
        when 'X'
          @extend_year += 1
        end

        OFF[Date.parse(r[0])] = exception
      end
    end

    if (opts[:extend_year] == true && @extend_year != 0)
      (1).upto(@extend_year) do
        if (opts[:last_day].friday?)
          opts[:last_day] += 3
        else
          opts[:last_day] += 1
        end
              
        # Check that we aren't ending on Juneteenth or some other early summer holiday.
        if (OFF.include?(opts[:last_day]))
          if (opts[:verbose] == true)
            puts "Extended year includes an off day (#{OFF[opts[:last_day]][:message]}), adding additional day."
          end
          opts[:last_day] += 1
        end
      end

      if (opts[:verbose] == true)
        puts "Extended calendar by #{@extend_year} days. Last day is now #{opts[:last_day]}."
      end
    elsif (opts[:extend_year] != true && @extend_year != 0)
      # Ensure that we don't extend the year even if there were snow days
      puts "No -x option on command line, did not extend the calendar by #{@extend_year} days."
      @extend_year = 0
    end
    add_events(opts)
  end

  def add_events(opts)
    count = 1   # A days are odd, B days are even.
    in_school = true

    opts[:first_day].upto(opts[:last_day]) do |date|
      if (OFF.include?(date))
        case (OFF[date][:reason])
        when 'F'
          # First day of school - (re)start output, reset rotation.
          # XXX - test this
          in_school = true
          count = 1
        when 'L'
          # Last day of school - stop output (allows multiple years in file)
          # XXX - test this
          in_school = false
          e = Icalendar::Event.new
          e.dtstart = Icalendar::Values::Date.new(date)
          e.summary = "#{(count % 2 == 1) ? 'A' : 'B'} Day"
          @cal.add_event(e)
          next
        when 'N'
          # Neutral day - pause A/B rotation
          e = Icalendar::Event.new
          e.dtstart = Icalendar::Values::Date.new(date)
          e.summary = "#{OFF[date][:message]}"
          @cal.add_event(e)
          next
        when 'R'
          # Start of a new semester, reset A/B day rotation.
          count = 1
        when 'X'
          # Day that extended the calendar (and slipped the rotation).
          e = Icalendar::Event.new
          e.dtstart = Icalendar::Values::Date.new(date)
          e.summary = "#{OFF[date][:message]}"
          @cal.add_event(e)
          next
        when ''
          # Break  - pause A/B rotation
          e = Icalendar::Event.new
          e.dtstart = Icalendar::Values::Date.new(date)
          e.summary = "#{OFF[date][:message]}"
          @cal.add_event(e)
          next
        else
          # Everything else.
          # XXX - warn about ignored reason tags.
	  puts("Reason #{OFF[date][:reason]} on date #{OFF[date]} not recognized.")
          next
        end
      end
      if (in_school && date.wday > 0 && date.wday < 6)
        e = Icalendar::Event.new
        e.dtstart = Icalendar::Values::Date.new(date)
	if (OFF.include?(date))
	  e.summary = "#{(count % 2 == 1) ? 'A' : 'B'} Day: #{OFF[date][:message]}"
	else
          e.summary = "#{(count % 2 == 1) ? 'A' : 'B'} Day"
	end
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
    o.on("-x")          { |v| opts[:extend_year] = v }

  end.parse!

  if (opts[:verbose] == true) then puts opts; end

  # TODO: validate opts before calling
  # TODO: require -f and -l options if F & L keys are not in off_file

  calendar = EventCreator.new(opts)
  calendar.to_ics(opts[:out_file])
end
