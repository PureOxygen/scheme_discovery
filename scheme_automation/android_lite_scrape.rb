# ruby -r "./scheme_automation/android_lite_scrape.rb" -e "AndroidLiteScrape.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'
require './scheme_automation/web_keyword_scraper.rb'

class AndroidLiteScrape

  def initialize
    @csv_array = []
    @apk_path = ("/Users/ericmckinney/desktop/scheme_discovery/android-apps")
  end

  def execute
    check_for_android_zips
    scrape
    delete_old_apps
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
        # scrape_manifest
        scrape_manifest_lite
        sleep(2)

        add_to_new_csv

      rescue => e
        puts "Error: #{e}"

      end
    end
  end

  def scrape_manifest_lite
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


    android_keywords = doc.search("intent-filter").each do |e|

      intent_data = e.children.to_s

      next unless intent_data.include?('android.intent.action.VIEW')
      next unless intent_data.include?('android.intent.category.DEFAULT')
      next unless intent_data.include?('android.intent.category.BROWSABLE')

      e.children.each do |data|
        data.each do |att_name, att_value|
          if att_name == "scheme"
            scheme = "scheme = '#{att_value}'"
            @csv_array << scheme
          elsif att_name == "host"
            host = "host = '#{att_value}'"
            @csv_array << host
          elsif att_name == "path"
            path = "path = '#{att_value}'"
            @csv_array << path
          elsif att_name == "pathPrefix"
            path_pre = "path == '#{att_value}'"
            @csv_array << path_pre
          end
        end
      end
    end
  end

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/#{@apk_name}.csv"
    File.open("./scheme_data/#{@apk_name}.csv", "w+") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
    @csv_array.clear
  end

  def delete_old_apps
    system `rm -rf ios-apps/*`
    system `rm -rf android-apps/*`
  end
  
end