# ruby -r "./web_keyword_scraper.rb" -e 'WebKeywordScraper.new("https://www.tiktok.com/@marshmellomusic?lang=en").scraper'
# ruby -r "./web_keyword_scraper.rb" -e 'WebKeywordScraper.new("https://www.instagram.com/p/CA7YyqcnJin/?utm_source=ig_web_copy_link").scraper'

require 'mechanize'
require 'webdrivers'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class WebKeywordScraper

  def initialize(url)
    @url = url
    @keywords = []
  end

  def scraper
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    list_page = a.get(@url)
    keywords
    rows = list_page.search '//meta'
    @find.each do |s|
      puts s
        rows.each do |row|
        if row['property'] == s
          @keywords << row['content']
        end
      end
    end
    puts @keywords
  end

  def keywords
    @find = [
      'al:ios:url',
      'android:url',
      'al:ios',
      'al:ios:url'
    ]
  end
end