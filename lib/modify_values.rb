require 'csv'

class ModifyValues
  def initialize(&blk)
    @filter = blk
  end

  def run(input, output=STDOUT)
    header = input.gets
    headers = CSV.parse_line(header)
    output.puts header

    input.each_line do |l|
      row = CSV.parse_line l, headers: headers
      @filter.call row
      output.puts CSV.generate_line row
    end
  end
end
