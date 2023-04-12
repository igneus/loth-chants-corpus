#!/usr/bin/env ruby

require_relative '../lib/modify_values'

ModifyValues
  .new do |row|
  if row['cycle'] == 'psalter'
    %w(month day day_title).each {|col| row[col] = nil }
  end
end
  .run(ARGF)
