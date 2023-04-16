require 'date'
require 'fileutils'

VERSIONS = %w(cz) # %w(cz czop la)
INPUT_DIR = 'input/source_files'
YEAR = Date.today.year

def version_dir(version)
  "include_#{version}"
end

desc 'fetch breviar.sk source files used here as input'
task :fetch do
  FileUtils.mkdir_p INPUT_DIR
  Dir.chdir(INPUT_DIR) do
    VERSIONS.each do |version|
      sh 'wget',
         '--recursive',
         '--level=2',
         '--no-host-directories',
         '--retry-on-http-error=503', # error quite often returned by the webserver and by default considered fatal by wget
         '--wait=4',
         '--random-wait',
         "https://lh.kbs.sk/#{version_dir(version)}/"
    end
  end
end

desc 'extract chant texts from input data'
task :extract do
  VERSIONS.each do |version|
    sh 'bin/extract.rb ' + version + ' ' + File.join(INPUT_DIR, version_dir(version)) # +
       # ' | bin/process.sh'
  end
end
