#!/usr/bin/env ruby
# coding: utf-8

require 'csv'

header = ARGF.gets

COL_CYCLE = 'cycle'
COL_WEEK = 'psalter_week'

headers = CSV.parse_line(header) + [COL_CYCLE, COL_WEEK]
puts CSV.generate_line headers

ARGF.each_line do |l|
  row = CSV.parse_line l, headers: headers

  row[COL_CYCLE] =
    case row['day_title']
    when /mezidobí/
      if row['day_title'] =~ /neděle/i && row['position'] == 'E'
        'temporale'
      else
        'psalter'
      end
    when /^sv\./i
      'sanctorale'
    else
      'temporale'
    end

  row[COL_WEEK] =
    row['day_title'].match(/([1-4]). týden žaltáře/) {|m| m[1] }

  puts CSV.generate_line row
end
