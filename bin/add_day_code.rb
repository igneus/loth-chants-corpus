#!/usr/bin/env ruby
# coding: utf-8

require_relative '../lib/add_columns'
require_relative '../lib/constants'

# day_code should be a language-agnostic code of the liturgical occasion
AddColumns
  .new
  .column('day_code') do |row|
  next 'saturday_memorial' if row['day_title'] =~ /sobotní památka/i

  case row['cycle']
  when Cycle::TEMPORALE
    nil # TODO
  when Cycle::SANCTORALE
    ['sanctorale', row['month'], row['day']].join '.'
  when Cycle::PSALTER
    ['psalter', row['psalter_week'], 'TODO:weekday'].join '.' # TODO
  else
    STDERR.puts row.inspect
    raise "unexpected cycle #{row['cycle']}"
  end
end
  .run(ARGF)
