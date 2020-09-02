# TO DOWNLOAD APK'S FOR REGRESSION TESTING USE THE DOWNLOADER IN `sheme_discovery/regression_tests`
# TO DOWNLOAD ANY APK IN THE play_store_links.csv
#
# ruby -r "./download_apk.rb" -e "DownloadApk.new.ex()"

require 'mechanize'
require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class DownloadApk

  def ex
    get_store_link
  end

  def get_store_link
    @download_count = 0
    File.open("app_data.csv","r").readlines.each do |line|
      begin
        google_play_link = line.split(',')[2]
        @download_count += 1
        download_apk(google_play_link)
      rescue => e
        puts "#{e}"
        next
      end
    end
    confirm_downloads_finished
  end

  def download_apk(store_link)
    options = Selenium::WebDriver::Chrome::Options.new
    @browser = Selenium::WebDriver.for :chrome, options: options
    package_name = store_link.split('id=').last.split('&').first
    download_link = "https://apkcombo.com/apk-downloader/?device=&arch=&android=&q=#{package_name}"
    @browser.get download_link
    sleep(5)
    @browser.find_element(class: '_center').click
    sleep(3)
  end

  def confirm_downloads_finished
    puts "Type 'y' once the downloads have finished"
    answer = gets.chomp
    sleep (5000) until answer == 'y'
    @browser.quit
    Dir.chdir("/Users/ericmckinney/desktop/scheme_discovery")
    move_downloads_to("#{Dir.pwd}/android-apps")
  end

  def move_downloads_to(dest_folder)
    Dir.chdir("/Users/ericmckinney/downloads")
    new_apps = Dir['*'].sort_by{ |f| File.mtime(f) }.last(@download_count)
    new_apps.each do |a|
      FileUtils.mv("/Users/ericmckinney/downloads/#{a}","#{dest_folder}/#{a}")
    end
  end
end