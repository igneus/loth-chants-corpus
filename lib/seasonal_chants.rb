require 'set'

class SeasonalChants
  def initialize(csv)
    @chants = Set.new

    csv.each do |row|
      @chants << self.class.seasonal_chant_properties(row)
    end
  end

  def include?(row)
    @chants.include? self.class.seasonal_chant_properties(row)
  end

  def self.load_from_file(path)
    new(CSV.parse(File.read(path), headers: true))
  end

  def self.seasonal_chant_properties(row)
    %w(hour genre position text season).collect {|i| row[i] }
  end
end
