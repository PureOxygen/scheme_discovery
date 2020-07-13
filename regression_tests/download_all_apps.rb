# ruby -r "./regression_tests/download_all_apps.rb" -e "DownloadAllApps.new.execute()"

require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
require 'headless'


class DownloadAllApps

  def initialize
    @version_array = []
    @app_names = []
  end

  def execute
    clean_up_csvs
    get_release_date
    add_to_csv
    app_count
    move_apks_from_new_to_old
    download_apk
    rename_apk
    move_apk
  end

  # This renames the new_versions.csv to old_versions.csv
  # This is required to gather the latest release dates of the apps and compare them
  def clean_up_csvs
    File.delete("./regression_tests/old_versions.csv")
    File.rename("./regression_tests/new_versions.csv", "./regression_tests/old_versions.csv")
  end

  # This is necessary to keep track of when the last version was released
  def get_release_date
    File.open("regression_tests/app_store_links.csv","r").readlines.each do |url|
      begin
        link = url.split(',')
        store_link = link[0]
        doc = Nokogiri::HTML(open(store_link))
        @release_date_div = doc.css('span.htlgb')[1]
        @release_date = @release_date_div.to_s.split('>').last.split('<').first
        @title_div = doc.css('h1.AHFaub').css('span')
        @title = @title_div.to_s.split('>').last.split('<').first.gsub('&acirc;','-').gsub(/&#['\d']['\d']['\d']\;/,'').gsub(/&amp;/,'')
        puts "#{@title}"
        puts "#{@release_date.chomp}"
        @version_array << ["#{@title}","#{@release_date}","#{store_link}"]
      end
    rescue => e
      puts "#{e}"
    end
  end

  # Adds apps name, release date, and store link to the new_versions.csv
  def add_to_csv
    File.open("./regression_tests/new_versions.csv", "wb") do |csv|
      @version_array.each do |line|
        csv.puts "#{line[0]},#{line[1]},#{line[2]}"
      end
    end
  end

  def app_count
    @download_count = File.open("./regression_tests/app_store_links.csv","r").readlines.size
    @total = File.open("./regression_tests/app_store_links.csv","r").readlines.size
  end

  def move_apks_from_new_to_old
    FileUtils.rm_rf('/Users/ericmckinney/desktop/android-regression/*old/')
    FileUtils.mv('/Users/ericmckinney/desktop/android-regression/*new/', '/Users/ericmckinney/desktop/android-regression/*old/')
    FileUtils.mkdir('/Users/ericmckinney/desktop/android-regression/*new/')
  end

  def download_apk
    File.open("./regression_tests/app_store_links.csv","r").readlines.each do |app_link|
      app_link = app_link unless app_link  == nil
      puts @app_name
      package_name = app_link.split('id=').last.split('&').first
      options = Selenium::WebDriver::Chrome::Options.new
      #options.add_argument('--headless')
      browser = Selenium::WebDriver.for :chrome, options: options
      download_link = "https://apkcombo.com/apk-downloader/?device=&arch=&android=&q=#{package_name}"
      browser.get download_link
      sleep(2)
      browser.find_element(class: '_center').click
      sleep(2)
      @download_count -= 1
      answer = 'n'
      if @download_count == 0
        puts "Type 'y' once the downloads have finished"
        answer = gets.chomp
        sleep (5000) until answer == 'y'
        browser.quit
      end
    end
  end

  def rename_apk
    Dir.chdir("/Users/ericmckinney/downloads")
    @new_apps = Dir['*'].sort_by{ |f| File.mtime(f) }.last(@total).reverse
    @name = @title.gsub(' ','_').downcase

    @new_apps.each do |a|
      binding.irb

      FileUtils.mv("/Users/ericmckinney/downloads/" + a, "/Users/ericmckinney/downloads/" + @name + File.extname(a) )
    end
  end

  def move_apk
    @new_apps.each do |a|
      FileUtils.mv("/Users/ericmckinney/downloads/" + @name + File.extname(a), "/Users/ericmckinney/desktop/android-regression/*new/" + @name + File.extname(a))
    end
  end
end

# TODO:
# -The problem is - I'm downloading everything at once, THAN I am renaming them - the program doesn't know which apk to rename - there is no order
# -I need to download the apk, wait until the file is not ending with .crdownload - AKA fully downloads, than I need to rename that file, and move it. All in one loop. One loop per app.
