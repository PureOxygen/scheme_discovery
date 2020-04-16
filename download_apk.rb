# TO DOWNLOAD APK'S FOR REGRESSION TESTING USE THE DOWNLOADER IN `sheme_discovery/regression_tests`
# TO DOWNLOAD ANY APK IN THE play_store_links.csv
# ruby -r "./download_apk.rb" -e "DownloadApk.new.download_apk_from_csv()"

require 'mechanize'
require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class DownloadApk

  def download_apk(store_link)

  end

  def download_apk_from_csv
    @download_count = 0
    begin
    File.open("play_store_links.csv","r").readlines.each do |line|
      google_play_link = line.split(/\n/).first
      package_name = google_play_link.split('id=').last.split('&').first
      options = Selenium::WebDriver::Chrome::Options.new
      #options.add_argument('--headless')
      browser = Selenium::WebDriver.for :chrome, options: options
      download_link = "https://apkcombo.com/apk-downloader/?device=&arch=&android=&q=#{package_name}"
      browser.get download_link
      sleep(2)
      browser.find_element(class: '_center').click
      sleep(3)
      @download_count += 1
    end

    until @download_count == 0
      Dir.chdir("/Users/ericmckinney/downloads")
      new_apps = Dir['*'].sort_by{ |f| File.mtime(f) }.last(@download_count)
      new_apps.each do |a|

        FileUtils.mv("/Users/ericmckinney/downloads/#{a}","/Users/ericmckinney/desktop/android-apps/#{a}")

        @download_count -= 1
      end
    end
    sleep(120)
    rescue => e
      puts "#"*100
      puts "Error finding CFBundleURLTypes in  Info.plist: #{e}"
      puts "#"*100
    end
  end
end