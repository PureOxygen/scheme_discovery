# ruby -r "./regression_tests/get_versions.rb" -e "GetVersions.new.execute()"

require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
require 'headless'

class GetVersions
  def initialize
    @version_array = []
    @app_names = []
  end

  def execute
    clean_up_csvs
    delete_apk_diffs
    get_release_date
    create_new_versions_csv
    compare_new_and_old
  end

  # This renames the new_versions.csv to old_versions.csv
  # This is required to gather the latest release dates of the apps and compare them
  def clean_up_csvs
    File.delete("./regression_tests/old_versions.csv")
    File.rename("./regression_tests/new_versions.csv", "./regression_tests/old_versions.csv")
  end

  def delete_apk_diffs
    FileUtils.rm_rf("./regression_tests/apk_diffs")
    FileUtils.mkdir("./regression_tests/apk_diffs")
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
  def create_new_versions_csv
    File.open("./regression_tests/new_versions.csv", "wb") do |csv|
      @version_array.each do |line|
        csv.puts "#{line[0]},#{line[1]},#{line[2]}"
      end
    end
  end

  def compare_new_and_old
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests")
    FileUtils.identical?('old_versions.csv','new_versions.csv')
    FileUtils.rm_rf("./update_diffs.csv")
    File.open("update_diffs.csv", "w") do |csv|
      csv.puts Diffy::Diff.new('old_versions.csv', 'new_versions.csv', :source => 'files')
    end
  end
end