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
    @path = []
    @ios = []
  end

  def execute
    Dir.foreach("./scheme_data") do |f|
      next if f == '.' or f == '..' or f.include? '*IOS'
      CSV.foreach("./scheme_data/#{f}") do |row|
        if row.to_s.include? "package"
          @package << row[0].split(/: /).last
        elsif row.to_s.include? "scheme"
          @scheme << row[0].split(/: /).last
        elsif row.to_s.include? "host"
          @host << row[0].split(/: /).last
        elsif row.to_s.include? "pathPattern"
          @path << row[0].split(/: /).last
        elsif row.to_s.include? "iOS"
          @ios << row[0].split(/: /).last
        end
      end

      generate_guesses

      binding.irb

    end
  end

  def generate_guesses

  end
end
