# ruby -r "./scheme_automation/web_keyword_scraper.rb" -e 'WebKeywordScraper.new("https://www.qvc.com/Joan-Rivers-Set-of-3-Shimmering-Stone-Wire-Earrings.product.J358645.html?sc=NAVLIST").execute'
# ruby -r "./scheme_automation/web_keyword_scraper.rb" -e 'WebKeywordScraper.new("https://www.atlutd.com/").execute'

require 'mechanize'
require 'webdrivers'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class WebKeywordScraper

  def initialize(url)
    @url = url
    @arr = []
    if @arr != []
      @arr.clear
    end
    @meta_tags = [
      'meta[name="branch:deeplink:$deeplink_path"]',
      'meta[property="al:iphone:url"]',
      'meta[property="al:ios:url"]',
      'meta[property="al:android:url"]',
      'meta[property="twitter:app:url:iphone"]',
      'meta[name="branch:deeplink:$ios_deeplink_path"]',
      'meta[name="al:ios:url"]',
      'meta[name="android:url"]',
      'meta[name="al:ios"]',
      'meta[name="al:ios:url"]'
    ]
  end

  def execute
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'iPhone'
    }
    sleep(5)
    list_page = a.get(@url)
    sleep(5)
    @meta_tags.each do |tag|
      begin
        deep_link = list_page.at(tag)[:content]
      rescue => e
        if tag == 'meta[name="al:ios:url"]'
          return @arr
        else
          next
        end
      end
      @arr << deep_link
      if @arr == []
        return "No meta tags of schemes were found on #{@app_name}'s website"
      else
        puts @arr
        return @arr
      end
    end
  end




















  #def initialize(url)
  #  @url = url
  #  @keywords = []
  #end
  #
  #def scraper
  #  a = Mechanize.new { |agent|
  #    agent.user_agent_alias = 'iPhone'
  #  }
  #  list_page = a.get(@url)
  #  keywords
  #  rows = list_page.search '//meta'
  #  @find.each do |s|
  #    puts s
  #      rows.each do |row|
  #      if row['property'] == s
  #        @keywords << row['content']
  #      end
  #    end
  #  end
  #  puts @keywords
  #end
  #
  #def keywords
  #  @find = [
  #    'al:ios:url',
  #    'android:url',
  #    'al:ios',
  #    'al:ios:url'
  #  ]
  #end
end