#!/usr/bin/env ruby

require 'set'

require_relative '../lib/filter_rows'
require_relative '../lib/add_columns'
require_relative '../lib/constants'

class PsalterUniq < FilterRows
  def initialize
    super do |row|
      row['cycle'] != Cycle::PSALTER ||
        unseen?(row)
    end

    @seen = Set.new
  end

  def unseen?(row)
    row_a = row.to_a
    r = !@seen.include?(row_a)
    @seen << row_a
    r
  end
end

PsalterUniq
  .new
  .run(ARGF)
