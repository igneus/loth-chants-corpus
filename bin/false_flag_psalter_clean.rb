#!/usr/bin/env ruby

require 'set'

require_relative '../lib/filter_rows'
require_relative '../lib/constants'

class DropFalseFlagPsalterChants < FilterRows
  def initialize(psalter_csv)
    @psalter_chants = Set.new
    CSV.parse(File.read(psalter_csv), headers: true).each do |row|
      @psalter_chants << psalter_chant_properties(row)
    end

    super() do |row|
      !is_false_flag_psalter_chant?(row)
    end
  end

  def is_false_flag_psalter_chant?(row)
    row['cycle'] != Cycle::PSALTER &&
      @psalter_chants.include?(psalter_chant_properties(row))
  end

  def psalter_chant_properties(row)
    %w(hour genre position text).collect {|i| row[i] }
  end
end

DropFalseFlagPsalterChants
  .new(ARGV[0])
  .run(STDIN)
