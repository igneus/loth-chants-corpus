#!/usr/bin/env ruby

require 'set'

require_relative '../lib/filter_rows'
require_relative '../lib/add_columns'
require_relative '../lib/constants'

class SaturdayMemorialUniq < FilterRows
  def initialize
    super do |row|
      row['day_code'] != 'saturday_memorial' ||
        unseen?(row)
    end

    @seen = Set.new
  end

  def unseen?(row)
    row_a = chant_properties row
    r = !@seen.include?(row_a)
    @seen << row_a
    r
  end

  def chant_properties(row)
    %w(hour genre position text).collect {|i| row[i] }
  end
end

SaturdayMemorialUniq
  .new
  .run(ARGF)
