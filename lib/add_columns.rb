require 'csv'

class AddColumns
  def initialize()
    @columns = {}
  end

  def column(name, &blk)
    @columns[name] = blk
    self
  end

  def run(input, output=STDOUT)
    header = input.gets
    headers = CSV.parse_line(header) + @columns.keys
    output.puts CSV.generate_line headers

    input.each_line do |l|
      row = CSV.parse_line l, headers: headers

      @columns.each_pair do |name, proc|
        row[name] = proc.call row
      end

      output.puts CSV.generate_line row
    end
  end
end
