#!/usr/bin/env ruby

require_relative '../lib/modify_values'
require_relative '../lib/constants'

ModifyValues
  .new do |row|
  if row['cycle'] == Cycle::PSALTER
    %w(month day date day_title).each {|col| row[col] = nil }
  end
end
  .run(ARGF)
