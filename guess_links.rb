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
          @package << row[0].split(/= /).last
        elsif row.to_s.include? "scheme"
          @scheme << row[0].split(/= /).last
        elsif row.to_s.include? "host"
          @host << row[0].split(/= /).last
        elsif row.to_s.include? "pathPattern"
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

      @host.product(@path).each do |combo|
        binding.irb
        host = combo[0].gsub('\'','')
        path = combo[1].gsub('\'','')
        package = @package[0].gsub('\'','')
        @scheme.count
        # Get a count of how many schemes in array
        # Index through each scheme for every loop
        # @scheme[0] - first loop
        # @scheme[1] - second loop
        # @scheme[2] - until length of scheme index
        #
        #
        binding.irb
        scheme = @scheme[@index+1] unless @index >= @index.count
        for s in (0...@scheme.size)
        end
      end

      puts "intent://#{combo[0]}#{combo[1]}#Intent;package=#{package};scheme=#{@scheme};end"

      binding.irb



      # @scheme.product(@host)

      generate_guesses

      binding.irb

    end
  end

  def generate_guesses

  end
end
