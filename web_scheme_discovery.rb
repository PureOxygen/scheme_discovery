# ruby -r "./web_scheme_discovery.rb" -e "WebSchemeDiscovery.new.execute()"

require 'mechanize'
require 'webdrivers'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class WebSchemeDiscovery

  def initialize
    @arr = []
    @meta_tags = [
      'meta[name="branch:deeplink:$deeplink_path"]',
      'meta[property="al:iphone:url"]',
      'meta[property="al:ios:url"]',
      'meta[property="al:android:url"]',
      'meta[property="twitter:app:url:iphone',
      'meta[name="branch:deeplink:$ios_deeplink_path"]',
      'meta[name="al:ios:url"]',
      'meta[name="android:url"]',
      'meta[name="al:ios"',
      'meta[name="al:ios:url"]',
    ]
  end

  def execute
    File.open("app_data.csv","r").readlines.each do |line|
      @apk_name = line.split(',')[2].chomp.split("id=").last
      @url = line.split(',').last.chomp
      scrape
    end
  end

  def scrape
    @meta_tags.each do |tag|
      begin
      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'iPhone'
      }
      list_page = a.get(@url)
      deep_link = list_page.at(tag)[:content]
      @arr << deep_link
      rescue => e
        next
      end
    end
    if @arr == []
      puts "No meta tags of schemes were found on #{@app_name}'s website"
    else
      puts @arr
    end
  end

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/#{@apk_name}.csv"
    File.open("./scheme_data/#{@apk_name}.csv", "wb") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end
end