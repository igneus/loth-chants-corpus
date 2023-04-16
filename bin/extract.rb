#!/usr/bin/env ruby

# Extracts chant texts and fundamental metadata from the breviar.sk exports

require_relative '../lib/chant_text_extractor'

lang, dir = ARGV

begin
  ChantTextExtractor.call dir, lang
rescue Errno::EPIPE
  # ok, no more output, exit
end
