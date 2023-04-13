#!/usr/bin/env ruby

require 'set'

require_relative '../lib/filter_rows'
require_relative '../lib/constants'
require_relative '../lib/seasonal_chants'

# selects single instance of each chant identified as seasonal
class DetectSeasonalChants < FilterRows
  # on how many days a chant must appear to be considered seasonal
  REPETITIONS_REQUIRED = 3

  def initialize
    super do |row|
      props = SeasonalChants.seasonal_chant_properties(row)

      row['cycle'] == Cycle::TEMPORALE &&
        !already_output?(props) &&
        required_appearances_satisfied?(props, row).tap {|satisfied| @already_output << props if satisfied }
    end

    @already_output = Set.new
    @appearance_counts = Hash.new
  end

  def already_output?(props)
    @already_output.include? props
  end

  def required_appearances_satisfied?(props, row)
    @appearance_counts[props] ||= Set.new
    @appearance_counts[props] << row['date']

    @appearance_counts[props].size >= REPETITIONS_REQUIRED
  end
end

DetectSeasonalChants
  .new
  .run(ARGF)
