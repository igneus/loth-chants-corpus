#!/usr/bin/env ruby

require_relative '../lib/add_columns'

# day_code should be a language-agnostic code of the liturgical occasion
AddColumns
  .new
  .column('day_code') do |row|
  case row['cycle']
  when 'temporale'
    nil # TODO
  when 'sanctorale'
    ['sanctorale', row['month'], row['day']].join '.'
  when 'psalter'
    ['psalter', row['psalter_week'], 'TODO:weekday'].join '.' # TODO
  else
    STDERR.puts row.inspect
    raise "unexpected cycle #{row['cycle']}"
  end
end
  .run(ARGF)
