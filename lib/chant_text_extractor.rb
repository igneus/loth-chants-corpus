require 'csv'

require 'nokogiri'

class ChantTextExtractor
  def self.call(dir)
    Dir["#{dir}/*/*_*.htm"].each do |f|
      next if f.include? '/docs/'
      process f
    end
  end

  def self.process(file)
    content = File.read file
    doc = Nokogiri::HTML(content)

    day = doc.xpath('//h2[2]/span').collect(&:text).join('; ')
    hour = doc.css('p.center span.uppercase').first.text

    chants = []

    # antiphons
    chants +=
      doc
        .css('p.strong')
        .select {|i| fc = i.children.first; fc.name == 'span' && fc.text =~ /ant.$/i }
        .collect {|i| i.children.collect {|y| y.text.strip }.reject(&:empty?) }
        .uniq {|i| i.last }

    file_cols = [
      File.basename(file),
      day,
      hour,
    ].collect do |s|
      # mainly remove line-breaks in feast titles
      s.gsub(/\s+/, ' ')
    end

    if chants.empty?
      STDERR.puts "NO CHANTS FOUND in #{file}"
    end

    chants.each do |c|
      puts CSV.generate_line(file_cols + c)
    end
  rescue => e
    STDERR.puts "Exception while processing #{file}:"
    raise
  end
end
