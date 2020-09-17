# ruby -r "./scheme_automation/guess_links.rb" -e "GuessLinks.new.execute()"

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
    @ext = []
    @web = []
    @csv_array = []
  end

  def execute
    Dir.foreach("./scheme_data") do |f|
      @csv_array.clear

      @csv_name = f
      next if f == '.' or f == '..' or f.include? '*IOS' or f.include? 'DS_Store'
      CSV.foreach("./scheme_data/#{f}") do |row|
        if row.to_s.include? '@'
          next
        elsif row.to_s.include? '.*'
          row[0].split(/= /).last.gsub('.*','x')
        elsif row.to_s.include? 'package'
          @package << row[0].split(/= /).last
        elsif row.to_s.include? 'scheme'
          @scheme << row[0].split(/= /).last
        elsif row.to_s.include? 'host'
          @host << row[0].split(/= /).last
        elsif row.to_s.include? 'path'
          @path << row[0].split(/= /).last
        elsif row.to_s.include? 'iOS'
          @host << row[0].split(/= /).last
        elsif row.to_s.include? 'web_domain'
          @web << row[0].split(/= /).last
        elsif row.to_s.include? 'ext'
          @ext << row[0].split(/= /).last
        end
      end

      @package = @package.uniq
      @scheme = @scheme.uniq
      @host = @host.uniq
      @path = @path.uniq
      @ios = @ios.uniq
      @web = @web.uniq
      @ext = @ext.uniq
      @index = 0

      if @path == []
        @path = ['']
      end

      package = @package[0].gsub('\'','')

      unless @ext == []
        ext = @ext[0].gsub("'","")
      end

      unless @web == []
        web = @web[0].gsub("'","")
      end

      unless @scheme == []
        if @scheme[0].include?("'")
          @scheme[0].gsub("'","")
        end
      end

      scheme1 = "*HTTP - With extension* \nintent://#{web}#{ext}/#Intent;package=#{package};scheme=http;end"
      scheme2 = "*HTTP - With WWW.* \nintent://www.#{web}#{ext}/#Intent;package=#{package};scheme=http;end"
      scheme3 = "*HTTP - With HTTPS:// and WWW.* \nintent://https://www.#{web}#{ext}/#Intent;package=#{package};scheme=http;end"
      @csv_array << "*############################################################################"
      @csv_array << scheme1
      @csv_array << scheme2
      @csv_array << scheme3

      scheme4 = "*HTTPS - With extension* \nintent://#{web}#{ext}/#Intent;package=#{package};scheme=https;end"
      scheme5 = "*HTTPS - With WWW.* \nintent://www.#{web}#{ext}/#Intent;package=#{package};scheme=https;end"
      scheme6 = "*HTTPS - With HTTPS:// and WWW.* \nintent://https://www.#{web}#{ext}/#Intent;package=#{package};scheme=https;end"
      @csv_array << "*############################################################################"
      @csv_array << scheme4
      @csv_array << scheme5
      @csv_array << scheme6

      @scheme.each do |scheme|
        if scheme.include?('\'')
          scheme.gsub('\'','')
        end

        if scheme.include?("'")
          scheme = scheme.gsub("'","")
        end


        @host.product(@path).each do |combo|
          host = combo[0].gsub('\'','')
          path = combo[1].gsub('\'','')
          package = @package[0].gsub('\'','')
          scheme7 = "*TYPICAL* \nintent://#{host}#{path}#Intent;package=#{package};scheme=#{scheme};end"
          scheme8 = "*IOS 1* \nintent://#Intent;package=#{package};scheme=#{host}:/#{path};end"
          scheme9 = "*IOS 2* \nintent:/#{path}#Intent;package=#{package};scheme=#{host};end"
          @csv_array << "*############################################################################"
          @csv_array << scheme7
          @csv_array << scheme8
          @csv_array << scheme9
        end
      end

      @scheme.each do |scheme|
        if scheme.include?('\'')
          scheme.gsub('\'','')
        end

        if scheme.include?("'")
          scheme = scheme.gsub("'","")
        end

        @web.product(@path).each do |combo|
          domain = combo[0].gsub('\'','')
          path = combo[1].gsub('\'','')
          package = @package[0].gsub('\'','')
          scheme10 = "*WEB FOR HOST* \nintent://#{domain}#{path}#Intent;package=#{package};scheme=#{scheme};end"
          scheme11 = "*IOS 3* \nintent://#Intent;package=#{package};scheme=#{domain}:/#{path};end"
          scheme12 = "*IOS 4* \nintent:/#{path}#Intent;package=#{package};scheme=#{domain};end"
          @csv_array << "*############################################################################"
          @csv_array << scheme10
          @csv_array << scheme11
          @csv_array << scheme12
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
      @web.clear
      @ext.clear
    end
  end
end
