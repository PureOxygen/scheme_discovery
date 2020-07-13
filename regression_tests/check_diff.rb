# ruby -r "./regression_tests/check_diff.rb" -e "CheckDiff.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'

class CheckDiff

  def initialize
    @apps = []
    @apk_path = ("/Users/ericmckinney/desktop/android-regression/*new")
  end

  def execute
    locate_apk
    get_updated_apps
    shuffle_files
    scrape # also runs scrap_manifest and add_to_csv
    get_diff
  end

  # Finds the file and converts it to a .apk using extract_zip IF it is a .zip file

  def locate_apk
    Dir.chdir(@apk_path)
    Dir.foreach(@apk_path) do |folder|
      next if folder == '.' or folder == '..' or folder.include? '.DS_Store' or folder.include? '.apk'
      if folder.include? '.zip'
        extract_zip(folder, @apk_path)
      end
    end
  end

  def extract_zip(file, destination)
    FileUtils.mkdir_p(destination)
    file = "#{destination}/#{file}"
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        fpath = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(fpath))
        zip_file.extract(f, fpath) unless File.exist?(fpath)
      end
    end
  end

  # This removes the csv file from old if it is new. It also moves new to old and replaces new with the newest scraped version.

  def shuffle_files
    #TODO: I need to change this to only move if the new app has been downloaded
    @apps.each do |a|
      if File.exist?("./regression_tests/old_apk/" + a + ".csv")
        FileUtils.rm_rf('./regression_tests/old_apk/' + a + ".csv")
        FileUtils.mv("./regression_tests/new_apk/" + a + ".csv","./regression_tests/old_apk/" + a + ".csv")
      elsif File.exist?("./regression_tests/new_apk/" + a + ".csv")
        FileUtils.mv("./regression_tests/new_apk/" + a + ".csv","./regression_tests/old_apk/" + a + ".csv")
      end
    end
  end

  # This creates an array of only the app-names for apps that have been updated

  def get_updated_apps
    Dir.chdir("/Users/ericmckinney/desktop/scheme_discovery")
    File.open("./regression_tests/update_diffs.csv","r").readlines.each do |app|
      @app = app unless app  == nil
      if app[0].include?('+')
        @app_name = @app.split('+').last.split(',').first.gsub(' ','')
        @apps << @app_name
      end
    end
  end

  def scrape
    begin
      Dir.chdir(@apk_path)
      Dir.foreach(@apk_path) do |folder|
        # This checks if the app matches the result of get_updated_apps - if not, the app has not been updated, so it won't get scraped

      next unless @apps.any? { |w| folder.include?(w)
        @apk_name = w
        }
        next unless folder.include? '.apk'


        Dir.chdir(@apk_path)

        system "apktool d #{@apk_path}/#{@apk_name} -f"

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
        links = "#{att_name}= '#{att_value}'"
        puts "#"*100
        @csv_array << links
        puts links
      end
    end
  end

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests")

    File.open("./new_apk/#{@apk_name}.csv", "wb") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end

  def get_diff
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests")

    Dir.foreach("./new_apk") do |new|
      next if new == '.' or new == '..'

      # TODO: Match on new name - all names should now be the same.
      binding.irb
      @match_name = new[0..6]

      Dir.foreach("./old_apk") do |old|
        next if old == '.' or old == '..'
        binding.irb
        if old.include? @match_name && !FileUtils.identical?("./old_apk/#{old}","./new_apk/#{new}")
          File.open("./apk_diffs/" + new, "wb") do |csv|
            csv.puts Diffy::Diff.new("./old_apk/" + old,"./new_apk/" + new, :source => 'files')
          end
          else puts "This is a new app - no older version to compare with."
        end
      end
    end
  end
end
