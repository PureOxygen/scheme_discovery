# ruby -r "./regression_tests/download_app.rb" -e "DownloadApp.new.execute(csv_app_data_line)"

require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
require 'headless'
require './regression_tests/get_versions.rb'
require './regression_tests/download_app.rb'

class DownloadApp

  def initialize
    @download_path = "/Users/ericmckinney/downloads"
  end

  def execute(csv_app_data_line)
    @app = csv_app_data_line
    download
  end

  def download
    @app = @app unless @app == nil
      package_name = @app.split('id=').last.split('&').first
      options = Selenium::WebDriver::Chrome::Options.new
      #options.add_argument('--headless')
      @browser = Selenium::WebDriver.for :chrome, options: options
      download_link = "https://apkcombo.com/apk-downloader/?device=&arch=&android=&q=#{package_name}"
      @browser.get download_link
      sleep(2)
      @browser.find_element(class: '_center').click
      sleep(2)
      if download_complete?
      end
    @browser.quit
  end

  def download_complete?
    @download_name = Dir.glob(File.join(@download_path, '*.*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
    puts @download_name
    if @download_name.include?(".crdownload")
      sleep(10)
      download_complete?
    end
  end

  #def rename_apk
  #  Dir.chdir(@download_path)
  #  ext_name = @download_name.split('.').last
  #  @app_name = @download_name.split("Downloads/").last.split('_').first.downcase.gsub(ext_name, '') + '.' + ext_name
  #  FileUtils.mv(@download_name, "/Users/ericmckinney/downloads/" + @app_name )
  #  move_apk
  #end

  #def move_apk
  #  FileUtils.mv("/Users/ericmckinney/downloads/" + @app_name, "/Users/ericmckinney/desktop/android-regression/*new/" + @app_name)
  #end
end