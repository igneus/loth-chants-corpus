#!/usr/bin/env ruby
# coding: utf-8

require_relative '../lib/add_columns'

AddColumns
  .new
  .column('psalter_week') {|row| row['day_title'].match(/([1-4]). týden žaltáře/) {|m| m[1] } }
  .column('cycle') do |row|
  next 'psalter' if row['hour'] == 'C' # Compline

  case row['day_title']
  when /mezidobí/
    if row['day_title'] =~ /neděle/i && row['position'] == 'E'
      'temporale'
    else
      'psalter'
    end
  when /(^sv\.|panny marie)/i
    'sanctorale'
  else
    'temporale'
  end
end
  .run(ARGF)
