require 'date'
require 'fileutils'

VERSIONS = %w(cz czop la)
INPUT_DIR = 'input'
YEAR = Date.today.year

desc 'fetch and unpack pre-generated breviar.sk output packages'
task :fetch do
  FileUtils.mkdir_p INPUT_DIR
  Dir.chdir(INPUT_DIR) do
    VERSIONS.each do |version|
      file = "#{YEAR}-#{version}-plain.zip"
      `wget https://breviar.sk/download/#{file}`
      `unzip -d #{version} #{file}`
    end
  end
end
