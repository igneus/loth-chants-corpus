#!/usr/bin/env ruby

# Filters CSV rows by a Ruby expression

require 'optparse'

require_relative '../lib/filter_rows'

expressions = []
OptionParser.new do |opts|
  opts.on '-e', '--expression=EXPR', 'Ruby expression to filter rows by' do |e|
    expressions << e
  end
end.parse!

FilterRows
  .new do |row|
  b = binding
  row.to_h.each_pair do |k, v|
    b.local_variable_set k, v
  end

  expressions.all? {|e| b.eval e }
end
  .run(ARGF)
