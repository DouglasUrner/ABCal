#!/usr/bin/env ruby

# TODO: validate date
# TODO: loop over dates in ARGV
# TODO: default to today
# TODO: write to stdout
# TODO: sort File
# TODO: ocmmit and push changes

require 'date'
require 'optparse'

opts = {}

OptionParser.new do |o|
  o.banner = "Usage: #{$0} [options]"

  o.on("-d DATE")     { |v| opts[:snow_day] = Date.parse(v) }
  o.on("-F FILENAME") { |v| opts[:filename]  = v }
  o.on("-h")          { puts o; exit }
  o.on("-v")          { |v| opts[:verbose] = v }

end.parse!

if (opts[:verbose] == true) then puts opts; end

File.open(opts[:filename], "a") { |f| f.write "#{opts[:snow_day]}\n" }
