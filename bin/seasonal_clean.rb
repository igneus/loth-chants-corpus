#!/usr/bin/env ruby

require_relative '../lib/modify_values'
require_relative '../lib/constants'
require_relative '../lib/seasonal_chants'

seasonal_chants = SeasonalChants.load_from_file ARGV[0]

ModifyValues
  .new do |row|
  next if row['cycle'] != Cycle::TEMPORALE

  if seasonal_chants.include? row
    %w(month day date day_title rank psalter_week day_code).each {|col| row[col] = nil }
  end
end
  .run(STDIN)
