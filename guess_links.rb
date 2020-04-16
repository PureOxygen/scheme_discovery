#TODO:
# Loop through android-apps and ios-apps excluding archive folder - get names of each one, and create a csv with all of the scripts
# Edit the scripts so they appear in order
# Run another command that runs each row in the csv file of scripts and outputs a csv for each app
#
# ruby -r "./guess_links.rb" -e "GuessLinks.new.execute()"

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
          @ios << row[0].split(/= /).last
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
          scheme1 = "intent://#{host}#{path}#Intent;package=#{package};scheme=#{scheme};end"
          scheme2 = "intent://#Intent;package=#{package};scheme=#{host}:/#{path};end"
          #scheme3 = "intent://#Intent;package=#{package};scheme=#{iOS}://#{pathPrefix};end"
          #scheme4 = "intent://#{pathPrefix}#Intent;package=#{package};scheme=#{iOS};end"
          puts "#{scheme1}"
          puts "#################"
          puts "#{scheme2}"
          puts ""
          puts "####################################"
          @csv_array << scheme1
          @csv_array << scheme2
        end
      end

    end
    add_to_csv
    clear_csv
  end

  def add_to_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/#{@csv_name}"
    File.open("#{@full_path}", "a") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end

  def clear_csv
    @csv_array.clear
  end
end
