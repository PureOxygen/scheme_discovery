# RUN FULL ON MANIFEST SCRAPE
# ruby -r "./scheme_automation/android_scheme_discovery.rb" -e "AndroidSchemeDiscovery.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'
require './scheme_automation/web_keyword_scraper.rb'

class AndroidSchemeDiscovery

  def initialize
    @csv_array = []
    @apk_path = ("/Users/ericmckinney/desktop/scheme_discovery/android-apps")
  end

  def execute
    check_for_android_zips
    scrape
  end

  def check_for_android_zips
    Dir.foreach(@apk_path) do |folder|
      if folder.include? '.zip'
        extract_zip(folder, @apk_path)
      end
    end
  end

  def extract_zip(file, destination)
    begin
      FileUtils.mkdir_p(destination)
      file = "#{destination}/#{file}"
      Zip::File.open(file) do |zip_file|
        zip_file.each do |f|
          fpath = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(fpath))
          zip_file.extract(f, fpath) unless File.exist?(fpath)
          zip_file.delete
        end
      rescue => e
        "Error: #{e}"
      end
    end
  end

  def scrape
    begin
      Dir.chdir(@apk_path)
      Dir.foreach(@apk_path) do |folder|
        next unless folder.include? '.apk'

        @apk_name = folder
        Dir.chdir(@apk_path)
        puts "looping through #{@apk_name}"

        # This expands the APK into it's own directory - if it see's the directory already exists it will ignore 'add_web_doman' and 'add_to_new_csv' because they are below it
        system "apktool d #{@apk_path}/#{@apk_name}"

        puts "scraping manifest"
        scrape_manifest
        sleep(2)

        puts "scraping web domain"
        # add_web_domain
        # scrape_web_domain
        add_to_new_csv

      rescue => e
        puts "Error: #{e}"

      end
    end
  end

  def scrape_manifest
    manifest_file_name = "#{@apk_path}/#{@apk_name}".gsub(".apk","")
    Dir.chdir(manifest_file_name)

    doc = Nokogiri.parse(File.read("AndroidManifest.xml"))
    filterData = "intent-filter.data."

    package_name = doc.search("manifest").each do |i|
      i.each do |att_name, att_value|
        if att_name.include? "package"
          att_value = "package = '#{att_value}'"
          @csv_array << att_value
          puts "#" * 100
          puts att_value
        end
      end
    end

    android_keywords = doc.search("data").each do |i|
      i.each do |att_name, att_value|
        links = "#{att_name} = '#{att_value}'"
        puts "#"*100
        @csv_array << links
        puts links
      end
    end
  end

  # def add_web_domain
  #   File.open("../../app_data.csv","r").readlines.each do |line|
  #     #next if line == '.' or line == '..' or line.include? '.DS_Store'
  #     package_name = @csv_array[0].split("'").last
  #     next unless line.include?(package_name)
  #     domain = line.split(',')[3].chomp unless nil || ',' || ''
  #     if domain.include?('www.')
  #       domain = domain.gsub('www.','')
  #     end
  #     host = domain.split('.').first.split('/').last unless domain == ""
  #     ext = domain.split(host).last.split('/').first unless domain == ""
  #     @csv_array << "web_domain = '#{host}'"
  #     @csv_array << "ext = '#{ext}'"
  #     @csv_array << "scheme = 'http'"
  #     @csv_array << "scheme = 'https'"
  #   end
  # end

  # def scrape_web_domain
  #   File.open("../../app_data.csv","r").readlines.each do |line|
  #     next unless line.include?(@apk_name.split('-').first) || line.include?(@apk_name.split('_').first)
  #     domain = line.split(',')[3].chomp unless nil || ',' || ''
  #     results = WebKeywordScraper.new(domain).execute unless domain == ""

  #     @csv_array << "web scraper = #{results}"
  #     results.clear unless results == nil
  #   end
  # end

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/#{@apk_name}.csv"
    File.open("./scheme_data/#{@apk_name}.csv", "w+") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
    @csv_array.clear unless @csv_array == nil
  end

  # TODO: Delete apps in both `ios-apps` and `android-apps` directories.
  # def run_ios_script
  #   IosSchemeDiscovery.new(@full_path).execute
  # end
end
