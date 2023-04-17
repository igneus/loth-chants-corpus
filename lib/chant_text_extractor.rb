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
    day = nil

    day_parts = doc.xpath('//h2[2]/span').collect(&:text)
    is_rank = lambda {|x| x =~ /slavnost|svátek|(?<!Sobotní )památka|připomínku/ }
    day_title = day_parts.reject(&is_rank).join(';; ')
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

    hour = nil
    doc
      .xpath('/html/body/*')
      .each do |para|
      # possible hour title
      # (hour titles are sometimes HTML elements, sometimes text nodes, only text matters)
      new_hour = untranslations['hours'][para.text.strip.downcase]
      if new_hour
        hour = new_hour
        next
      end

      next unless para.element? && para.name == 'p'

      # sanctorale, day title
      if basename.start_with?('sv_') && para[:class] == 'center strong' && para.text.strip =~ /^(Též\s+)?(\d+)\.\s+(ledna|února|března|dubna|května|června|července|srpna|září|října|listopadu|prosince)$/
        day = $2.to_s
        day_title = para.xpath("./following-sibling::p[@class='strong'][1]").text.strip
        next
      end

      # antiphon
      if para.xpath("./span[@class='red']") &&
         para.children.first&.then {|fc| fc.name == 'span' && fc.text =~ /ant(\.|ifona k)/i }
        i = para.children.reject(&:comment?).collect {|y| y.text.strip }.reject(&:empty?)[0..1]
        text = strip_nbsp.(i[1])
        next if chants&.last&.last == text # repetition of the antiphon after the psalm
        chants << [
          Genre::ANTIPHON,
          i[0].then {|label| label =~ /(ke kant\. P\. M\.|k_Zach\. kant\.)/ ? Position::GOSPEL_ANTIPHON : label.scan(/\d/)[0] },
          text
        ]
        next
      end

      # short responsory
      if para[:class] == 'redsmall' && para.text.strip.downcase == 'zpěv po krátkém čtení'
        # two subsequent p.respV siblings are interesting for us
        chants << [
          Genre::RESPONSORY_SHORT,
          nil,
          strip_nbsp.(
            para.xpath("./following-sibling::p[@class='respV'][1]").text.strip.gsub('{*}', '*') +
            ' V. ' +
            para.xpath("./following-sibling::p[@class='respV'][2]").text.strip
          )
        ]
      end
    end

    file_cols = [
      basename,
      month,
      day,
      day_title,
      untranslations['ranks'][rank] || rank,
      hour,
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
