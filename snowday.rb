#!/usr/bin/env ruby

# TODO: validate date
# TODO: loop over dates in ARGV
# TODO: default to today
# TODO: write to stdout
# TODO: sort File
# TODO: ocmmit and push changes

require 'date'
require 'optparse'

today = Date::today.strftime('%Y-%m-%d')

opts = {
  date: (Date::today.strftime('%Y-%m-%d')),
  reason: 'X',
  message: 'Snow Day'
}

OptionParser.new do |o|
  o.banner = "Usage: #{$0} [options]"

  o.on('-d DATE')     { |v| opts[:date] = Date.parse(v) }
  o.on('-I FILENAME') { |v| opts[:filename] = v }
  o.on('-h')          { puts o; exit }
  o.on('-m MESSAGE')  { |v| opts[:message] = v }
  o.on('-r REASON')   { |v| opts[:reason] = v }
  o.on('-v')          { |v| opts[:verbose] = v }

end.parse!

if (opts[:verbose] == true) then
  puts opts
  puts "#{opts[:date]} #{opts[:message]}\n"
end

File.open(opts[:filename], 'a') do |f|
  f.write "#{opts[:date]}|#{opts[:reason]}|#{opts[:message]}\n"
end
