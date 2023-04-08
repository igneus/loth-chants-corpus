#!/usr/bin/env ruby

# Filters CSV rows by a Ruby expression

require 'csv'
require 'optparse'

expressions = []
OptionParser.new do |opts|
  opts.on '-e', '--expression=EXPR', 'Ruby expression to filter rows by' do |e|
    expressions << e
  end
end.parse!

filter = lambda do |row|
  b = binding
  row.to_h.each_pair do |k, v|
    b.local_variable_set k, v
  end

  expressions.all? {|e| b.eval e }
end

headers = CSV.parse_line ARGF.gets
ARGF.each_line do |l|
  row = CSV.parse_line l, headers: headers
  print l if filter.(row)
end
