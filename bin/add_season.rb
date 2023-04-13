#!/usr/bin/env ruby
# coding: utf-8

require 'date'
require 'calendarium-romanum/cr'

require_relative '../lib/add_columns'

# rather than scraping season from the HTML files we combine the scraped data
# with a separate data source - liturgical calendar.
calendar = CR::PerpetualCalendar.new

AddColumns
  .new
  .column('season') do |row|
  date = Date.parse row['date']

  calendar[date].season.symbol.to_s
end
  .run(ARGF)
