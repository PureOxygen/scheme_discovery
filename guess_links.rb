# ruby -r "./guess_links.rb" -e "GuessLinks.new.execute()"

#TODO:
# Loop through android-apps and ios-apps excluding archive folder - get names of each one, and create a csv with all of the scripts
# Edit the scripts so they appear in order
# Run another command that runs each row in the csv file of scripts and outputs a csv for each app


require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'

class GuessLinks

  def initialize
    @package = []
    @scheme = []
    @host = []
    @path = ['/']
    @ios = []
    @csv_array = []
  end

  def execute
    Dir.foreach("./scheme_data") do |f|
      @csv_array.clear

      @csv_name = f
      next if f == '.' or f == '..' or f.include? '*IOS'
      CSV.foreach("./scheme_data/#{f}") do |row|
        if row.to_s.include? "package"
          @package << row[0].split(/= /).last
        elsif row.to_s.include? "scheme"
          @scheme << row[0].split(/= /).last
        elsif row.to_s.include? "host"
          @host << row[0].split(/= /).last
        elsif row.to_s.include? "path"
          @path << row[0].split(/= /).last
        elsif row.to_s.include? "iOS"
          @host << row[0].split(/= /).last
        end
      end

      @package = @package.uniq
      @scheme = @scheme.uniq
      @host = @host.uniq
      @path = @path.uniq
      @ios = @ios.uniq
      @index = 0

      @scheme.each do |scheme|
        scheme = scheme.gsub('\'','')
        @host.product(@path).each do |combo|
          host = combo[0].gsub('\'','')
          path = combo[1].gsub('\'','')
          package = @package[0].gsub('\'','')
          scheme1 = "*TYPICAL INTENT* \n intent://#{host}#{path}#Intent;package=#{package};scheme=#{scheme};end"
          scheme2 = "*IOS 1* \n intent://#Intent;package=#{package};scheme=#{host}:/#{path};end"
          scheme3 = "*IOS 1* \n intent:/#{path}#Intent;package=#{package};scheme=#{host};end"
          @csv_array << scheme1
          @csv_array << scheme2
          @csv_array << scheme3
          @csv_array << "############################################################################"
        end
      end
      add_to_csv
    end

  end

  def add_to_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/#{@csv_name}"
    File.open("#{@full_path}", "a") do |f|
      @csv_array.each do |row|
        f.puts row
      end
      @csv_array.clear
      @package.clear
      @scheme.clear
      @host.clear
      @path.clear
      @ios.clear
    end
  end
end
