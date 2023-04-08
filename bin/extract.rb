#!/usr/bin/env ruby

# Extracts chant texts and fundamental metadata from the breviar.sk exports

require_relative '../lib/chant_text_extractor'

begin
  ARGV.each {|dir| ChantTextExtractor.call dir }
rescue Errno::EPIPE
  # ok, no more output, exit
end
