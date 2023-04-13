#!/usr/bin/env ruby

require 'set'

require_relative '../lib/filter_rows'
require_relative '../lib/constants'
require_relative '../lib/seasonal_chants'

class SeasonalUniq < FilterRows
  def initialize
    super do |row|
      row['cycle'] != Cycle::TEMPORALE ||
        row['date'] != nil ||
        unseen?(row)
    end

    @seen = Set.new
  end

  def unseen?(row)
    row_a = SeasonalChants.seasonal_chant_properties row
    r = !@seen.include?(row_a)
    @seen << row_a
    r
  end
end

SeasonalUniq
  .new
  .run(ARGF)
