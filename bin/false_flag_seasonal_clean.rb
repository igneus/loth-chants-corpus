#!/usr/bin/env ruby

require_relative '../lib/filter_rows'
require_relative '../lib/constants'
require_relative '../lib/seasonal_chants'

class DropFalseFlagSeasonalChants < FilterRows
  def initialize(seasonal_csv)
    @seasonal_chants = SeasonalChants.load_from_file seasonal_csv

    super() do |row|
      !is_false_flag_seasonal_chant?(row)
    end
  end

  def is_false_flag_seasonal_chant?(row)
    row['cycle'] != Cycle::TEMPORALE &&
      @seasonal_chants.include?(row)
  end
end

DropFalseFlagSeasonalChants
  .new(ARGV[0])
  .run(STDIN)
