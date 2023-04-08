#!/usr/bin/env ruby

require_relative '../lib/chant_text_extractor'

ARGV.each {|dir| ChantTextExtractor.call dir }
