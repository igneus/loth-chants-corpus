#!/usr/bin/env ruby
# coding: utf-8

require_relative '../lib/add_columns'
require_relative '../lib/constants'

AddColumns
  .new
  .column('psalter_week') {|row| row['day_title'].match(/([1-4]). týden žaltáře/) {|m| m[1] } }
  .column('cycle') do |row|
  next Cycle::PSALTER if row['hour'] == Hour::COMPLINE

  case row['day_title']
  when /mezidobí/
    if row['day_title'] =~ /neděle/i && row['position'] == Position::GOSPEL_ANTIPHON
      Cycle::TEMPORALE
    else
      Cycle::PSALTER
    end
  when /(^sv\.|panny marie|křtitele)/i
    Cycle::SANCTORALE
  else
    Cycle::TEMPORALE
  end
end
  .run(ARGF)
