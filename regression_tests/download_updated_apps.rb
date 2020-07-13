# ruby -r "./regression_tests/download_updated_apps.rb" -e "DownloadUpdatedApps.new.execute()"

require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
require 'headless'


class DownloadUpdatedApps

  def initialize
    @version_array = []
    @app_names = []
  end

  def execute
    clean_up_csvs
    get_release_date
    add_to_csv
    compare_csv
    new_app_count
    new_version?
    move_apk
  end

  # This renames the new_versions.csv to old_versions.csv
  # This is required to gather the latest release dates of the apps and compare them
  def clean_up_csvs
    File.delete("./regression_tests/old_versions.csv")
    File.rename("./regression_tests/new_versions.csv", "./regression_tests/old_versions.csv")
  end

  # This scrapes all the google play store links found in app_store_links.csv and gets the release date
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

  # Compares new_versions.csv with old_versions.csv using diffy and updates the update_diffs.csv
  def compare_csv
    FileUtils.identical?('./regression_tests/old_versions.csv','./regression_tests/new_versions.csv')
    File.open("./regression_tests/update_diffs.csv", "w") do |csv|
      csv.puts Diffy::Diff.new('./regression_tests/old_versions.csv', './regression_tests/new_versions.csv', :source => 'files')
    end
  end

  def new_app_count
    @download_total = 0
    @download_count = 0
    File.open("./regression_tests/update_diffs.csv","r").readlines.each do |a|
      if a[0] == '+'
        @download_total += 1
        @download_count += 1
      end
    end
  end

  def new_version?
    File.open("./regression_tests/update_diffs.csv","r").readlines.each do |app|
      @app = app unless app  == nil
      @app_names << @app.split('+').last.split(',').first.gsub(' ','')
      if app[0].include?('+')
        move_apk_from_new_to_old
        download_apk
        rename_apk
      end
    end
  end

  # Moves the actual apk to the *old directory if it already exists in the *new directory

  def move_apk_from_new_to_old
    if File.exist?('/Users/ericmckinney/desktop/android-regression/*old/' + @app_name)
      File.delete('/Users/ericmckinney/desktop/android-regression/*old/' + @app_name)
    end
    if File.exist?('/Users/ericmckinney/desktop/android-regression/*new/' + @app_name)
      FileUtils.mv('/Users/ericmckinney/desktop/android-regression/*new/' + @app_name, '/Users/ericmckinney/desktop/android-regression/*old/' + @app_name)
    else
      puts "App has no older version to compare it to"
    end
  end

  def download_apk
    puts @app_name
    google_play_link = @app.split(',').last
    package_name = google_play_link.split('id=').last.split('&').first
    options = Selenium::WebDriver::Chrome::Options.new
    #options.add_argument('--headless')
    browser = Selenium::WebDriver.for :chrome, options: options
    download_link = "https://apkcombo.com/apk-downloader/?device=&arch=&android=&q=#{package_name}"
    browser.get download_link
    sleep(5)
    browser.find_element(class: '_center').click
    sleep(5)
    @download_count -= 1
    answer = 'n'
    if @download_count == 0
      puts "Type 'y' once the downloads have finished"
      answer = gets.chomp
      sleep (5000) until answer == 'y'
      browser.quit

    end
  end

  def rename_apk
    Dir.chdir("/Users/ericmckinney/downloads")
    @new_apps = Dir['*'].sort_by{ |f| File.mtime(f) }.last(@download_total).reverse
    @new_apps.each do |a|
      binding.pry
      FileUtils.mv("/Users/ericmckinney/downloads/" + a, "/Users/ericmckinney/downloads/" + @app_name + File.extname(a) )
    end
  end

  def move_apk
    @new_apps.each do |a|
      FileUtils.mv("/Users/ericmckinney/downloads/" + @app_name + File.extname(a), "/Users/ericmckinney/desktop/android-regression/*new/" + @app_name + File.extname(a))
    end
  end
end


