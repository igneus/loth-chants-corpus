require 'csv'

class FilterRows
  def initialize(&blk)
    @filter = blk
  end

  def run(input, output=STDOUT)
    header = input.gets
    headers = CSV.parse_line(header)
    output.puts header

    input.each_line do |l|
      row = CSV.parse_line l, headers: headers
      output.print l if @filter.call row
    end
  end
end
