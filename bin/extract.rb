#!/usr/bin/env ruby

require_relative '../lib/chant_text_extractor'

begin
  ARGV.each {|dir| ChantTextExtractor.call dir }
rescue Errno::EPIPE
  # ok, no more output, exit
end
