# coding: utf-8
require 'csv'
require 'yaml'

require 'nokogiri'

require_relative '../lib/constants'

class ChantTextExtractor
  MONTHS = %w(jan feb mar apr maj jun jul aug sep okt nov dec).freeze

  def self.call(dir, lang)
    untranslations = YAML.load File.read "untranslations/#{lang}.yml"

    puts CSV.generate_line([
      'basename',
      'month',
      'day',
      'day_title',
      'rank',
      'hour',
      'cycle',
      'psalter_week',
      'season',
      'genre',
      'position',
      'text',
    ])

    Dir["#{dir}/*.htm"]
      .reject {|f| File.basename(f).start_with? 'pro_' } # propers of religious institutes
      .each do |f|
      next if f.include? '/docs/'
      process f, untranslations
    end
  end

  def self.process(file, untranslations)
    content = File.read file
    doc = Nokogiri::HTML(content)

    basename = File.basename(file)
    month = basename.match(/^sv_(.+?)\.htm/) {|m| MONTHS.index(m[1]) + 1 }&.to_s
    day = nil # TODO

    day_parts = doc.xpath('//h2[2]/span').collect(&:text)
    is_rank = lambda {|x| x =~ /slavnost|svátek|(?<!Sobotní )památka|připomínku/ }
    day_title = day_parts.reject(&is_rank).join(';; ')
    #hour = doc.css('p.center span.uppercase').first.text
    hour = nil
    rank = day_parts.find(&is_rank)
    cycle =
      case basename
      when /^_/
        Cycle::PSALTER
      when /s[vc]_/
        Cycle::SANCTORALE
      else
        Cycle::TEMPORALE
      end
    psalter_week = basename.match(/^_(\d)/) {|m| m[1] }
    season =
      case basename
      when /adv/
        Season::ADVENT
      when /post/
        Season::LENT
      when /cezrok/
        Season::ORDINARY
      else
        nil
      end

    chants = []

    # Nokogiri translates &nbsp; to a Unicode non-breaking space, which we do not like
    strip_nbsp = -> (x) { x&.gsub("_", ' ') }

    # antiphons
    chants +=
      doc
        .xpath("//p[./span[@class='red']]")
        .select {|i| fc = i.children.first; fc.name == 'span' && fc.text =~ /ant(\.|ifona k)/i }
        #.tap {|x| pp x }
        .collect {|i| i.children.reject(&:comment?).collect {|y| y.text.strip }.reject(&:empty?)[0..1] }
        .uniq {|i| i.last }
        .collect do |i|
      [
        Genre::ANTIPHON,
        i[0].then {|label| label =~ /(ke kant\. P\. M\.|k_Zach\. kant\.)/ ? Position::GOSPEL_ANTIPHON : label.scan(/\d/)[0] },
        strip_nbsp.(i[1])
      ]
    end

    # short responsories
    chants +=
      doc
        .xpath("//div[@class='respons' and count(./p[@class='respV']) > 2]")
        .collect {|i| i.xpath("./p[@class='respV']") }
        .collect {|j| j[0].text.strip + ' V. ' + j[1].text.strip }
        .collect {|i| [Genre::RESPONSORY_SHORT, nil, strip_nbsp.(i)] }

    file_cols = [
      basename,
      month,
      day,
      day_title,
      untranslations['ranks'][rank] || rank,
      untranslations['hours'][hour] || hour,
      cycle,
      psalter_week,
      season,
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
