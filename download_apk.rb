# ruby -r "./download_apk.rb" -e "DownloadApk.new.get_apk()"

require 'mechanize'
require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'pry'
require 'open-uri'

class DownloadApk

  def initiliaze
  end

  def get_apk
    File.open("play_store_links.csv","r").readlines.each do |line|
      @download_link = line.gsub(/\n/,'')
      prefix = @download_link.split('.com').last
      reg_link = "https://www.apkpure.com#{prefix}"
      doc = Nokogiri::HTML(open(reg_link))
      href = doc.css('.da').to_s.split('href="').last.split('">').first
      link = "https://www.apkpure.com#{href}"
      browser = Watir::Browser.new :chrome
      browser.goto(link)
      sleep 2
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found' || e.message == '410 Gone'
        next
      end
    end
  end
end