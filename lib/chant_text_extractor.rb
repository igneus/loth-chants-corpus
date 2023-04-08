# coding: utf-8
require 'csv'
require 'yaml'

require 'nokogiri'

class ChantTextExtractor
  def self.call(dir)
    untranslations = YAML.load File.read "untranslations/#{File.basename(dir)}.yml"
    Dir["#{dir}/*/*_*.htm"].each do |f|
      next if f.include? '/docs/'
      process f, untranslations
    end
  end

  def self.process(file, untranslations)
    basename = File.basename(file)
    month = basename[2..3]
    day = basename[4..5]

    content = File.read file
    doc = Nokogiri::HTML(content)

    day_parts = doc.xpath('//h2[2]/span').collect(&:text)
    is_rank = lambda {|x| x =~ /slavnost|svátek|památka/ }
    day_title = day_parts.reject(&is_rank).join('; ')
    hour = doc.css('p.center span.uppercase').first.text
    rank = day_parts.find(&is_rank)

    chants = []

    # Nokogiri translates &nbsp; to a Unicode non-breaking space, which we do not like
    strip_nbsp = -> (x) { x&.gsub("\u00A0", ' ') }

    # antiphons
    chants +=
      doc
        .xpath("//p[./span[@class='red']]")
        .select {|i| fc = i.children.first; fc.name == 'span' && fc.text =~ /ant(\.|ifona k)/i }
        .collect {|i| i.children.collect {|y| y.text.strip }.reject(&:empty?)[0..1] }
        .uniq {|i| i.last }
        .collect {|i| ['A', i[0].scan(/\d/)[0], strip_nbsp.(i[1])] }

    # short responsories
    chants +=
      doc
        .xpath("//div[@class='respons' and count(./p[@class='respV']) > 2]")
        .collect {|i| i.xpath("./p[@class='respV']") }
        .collect {|j| j[0].text.strip + ' V. ' + j[1].text.strip }
        .collect {|i| ['Rb', nil, strip_nbsp.(i)] }

    file_cols = [
      basename,
      month,
      day,
      day_title,
      rank,
      untranslations['hours'][hour] || hour,
    ].collect do |s|
      # mainly remove line-breaks in feast titles
      s&.gsub(/\s+/, ' ')
    end

    if chants.empty?
      STDERR.puts "NO CHANTS FOUND in #{file}"
    end

    chants.each do |c|
      puts CSV.generate_line(file_cols + c)
    end
  rescue Errno::EPIPE
    raise
  rescue => e
    STDERR.puts "Exception while processing #{file}:"
    raise
  end
end
