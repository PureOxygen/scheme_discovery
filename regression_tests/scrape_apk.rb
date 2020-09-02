# ruby -r "./regression_tests/scrape_apk.rb" -e "ScrapeApk.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'
require './regression_tests/download_app.rb'


class ScrapeApk

  def initialize
    @apk_path = ("/Users/ericmckinney/desktop/android-regression/*new")
  end

  def execute
    move_csvs
    check_for_android_zips
    locate_apk
    scrape
    add_to_new_csv
  end

  def move_csvs
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/csv_compare")
    FileUtils.rm_rf("./old")
    FileUtils.mv("./new","./old")
    Dir.mkdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/csv_compare/new")
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

  def locate_apk
    Dir.chdir(@apk_path)
    Dir.foreach(@apk_path) do |folder|
      next if folder == '.' or folder == '..' or folder.include? '.DS_Store' or folder.include? '.apk'
    end
  end

  def scrape
    begin
      Dir.chdir(@apk_path)
      Dir.foreach(@apk_path) do |folder|
        next unless folder.include? '.apk'

        @apk_name = folder
        Dir.chdir(@apk_path)

        system "apktool d #{@apk_path}/#{@apk_name}"

        scrape_manifest
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

    @csv_array = []

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

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/csv_compare/new")
    @full_path = "#{@apk_name}.csv"
    File.open("#{@apk_name}.csv", "wb") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end

  def csv_name
    return @full_path
  end

  # TODO: Delete apps in both `ios-apps` and `android-apps` directories.
  def run_ios_script
    IosSchemeDiscovery.new(@full_path).execute
  end
end

# Run get_versions.rb

# 1. Loop through update_diffs and grab anything with a '+'
# 1. Delete *old directory, rename *new directory to *old directory, create *new directory
# 2. Download the app using the download_app class
# 3. Rename the apk to be the package - example: `com.linkein.android.apk`
# 4. Move the app to the *new directory
# 5. Extract if it's a zip
# 6. Scrape
# 7. Check if CSV is in csv_compare/new, if it is check to see if it is in csv_compare/old, if it is delete from old and move new to old, if it's not move new to old
# 8. Create CSV and place in /new
# 9. if old/new are identicle, compare with diffy
#
