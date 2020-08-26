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
    @apps = []
    @new_apk_path = ("/Users/ericmckinney/desktop/android-regression/*new")
    @old_apk_path = ("/Users/ericmckinney/desktop/android-regression/*old")
    @new_csv_path = ("/Users/ericmckinney/desktop/scheme_discovery/regression_tests/csv_compare/new/")
    @old_csv_path = ("/Users/ericmckinney/desktop/scheme_discovery/regression_tests/csv_compare/old/")
    @download_path = ("/Users/ericmckinney/downloads")
    @diffs_path = "/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/apk_diffs"
    @csv_array = []
  end

  def execute
    remove_old_apks
    remove_old_diffs
    loop_through_newly_released
  end

  def remove_old_apks
    FileUtils.rm_rf(@old_apk_path)
    FileUtils.mv(@new_apk_path, @old_apk_path)
    FileUtils.mkdir(@new_apk_path)
  end

  def loop_through_newly_released
    Dir.chdir("/Users/ericmckinney/desktop/scheme_discovery/regression_tests")
    File.open("update_diffs.csv","r").readlines.each do |line|
      line = line unless line  == nil
      if line[0].include?('+')
        @app_name = line.split('id=').last.split('&').first
        DownloadApp.new.execute(line)
        rename_apk
        move_apk
        check_if_old_csv
        check_if_new_csv
        locate
        scrape
        add_to_new_csv
        get_diff
        clear_array
      end
    end
  end

  def rename_apk
    Dir.chdir(@download_path)
    #ext_name = @download_name.split('.').last
    @download_name = Dir.glob(File.join(@download_path, '*.*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
    @ext = @download_name.split('.').last
    FileUtils.mv(@download_name, @download_path + '/' + @app_name + '.' + @ext )
  end

  def move_apk
    @app_path = @new_apk_path + '/' + @app_name + '.' + @ext
    FileUtils.mv(@download_path + '/' + @app_name + '.' + @ext, @new_apk_path)
  end

  # Finds the zip and converts it to an .apk using extract_zip IF it is a .zip file
  def locate
    Dir.chdir(@new_apk_path)
      if @app_path.include? '.zip'
        @zip_dest = @app_path.gsub('.zip','')
        extract_zip(@app_path, @zip_dest)
        sleep(2)
    end
  end

  def extract_zip(file, destination)
    FileUtils.mkdir_p(destination)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        f_path=File.join(destination, f.name)
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
  end

  def check_if_old_csv
    Dir.chdir(@old_csv_path)
    file = File.join(@old_csv_path, @app_name + ".csv")
    if File.exists?(file)
      File.delete(file)
    end
  end

  def check_if_new_csv
    Dir.chdir(@new_csv_path)
    @app_name = @app_name.chomp
    file = File.join(@new_csv_path, @app_name + ".csv")
    if File.exist?(file)
      FileUtils.mv(@new_csv_path + @app_name + ".csv", @old_csv_path + @app_name + ".csv")
    end
  end

  def scrape
    #begin
      @app_path = Dir.glob(File.join(@new_apk_path, '*.*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
      Dir.chdir(@new_apk_path)
      #Dir.foreach(@new_apk_path) do |folder|

        #next if folder == '.' || folder == ".."
        if @app_path.include?(".apk")

          scrape_manifest

        else
          Dir.foreach(@app_path) do |sub_folder|
            #next unless sub_folder.include?(@app_name) && sub_folder.include?(".apk")
            #@apk = folder + '/' + sub_folder

            binding.irb
            scrape_manifest
            
          end
        #end
      #rescue => e
      #  puts "Error: #{e}"
      #
      #end
    end
  end

  def scrape_manifest
    # is this looking for the path if it is a sub_folder?
    Dir.chdir(@new_apk_path)
    binding.irb
    system "apktool d #{@app_path} -f --no-res"
    manifest_file_name = "#{@app_path}".gsub(".apk","")
    Dir.chdir(manifest_file_name)
    sleep(5)
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
        links = "#{att_name}= '#{att_value}'"
        puts "#"*100
        @csv_array << links
        puts links
      end
    end
  end

  def add_to_new_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests")
    File.open("./csv_compare/new/#{@app_name}.csv", "wb") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end

  def remove_old_diffs
    FileUtils.rm_rf(@diffs_path)
    Dir.mkdir(@diffs_path)
  end

  def get_diff
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/csv_compare")
    Dir.foreach("./new") do |new|
      next unless new.include?(@app_name)

      Dir.foreach("old") do |old|
        next unless old.include?(@app_name)
        if File.exists?(@old_csv_path + "/" + "#{old}") && File.exists?(@new_csv_path + "/" + "#{new}")
        #if FileUtils.identical?(@old_csv_path + "/" + "#{old}", @new_csv_path + "/" + "#{new}")
          File.open(@diffs_path + '/' + new, "wb") do |csv|
            csv.puts Diffy::Diff.new("old/" + old,"new/" + new, :source => 'files', :allow_empty_diff => false)
          end
          else puts "This is new to the test - no older version to compare with."
        end
      end
    end
  end

  def clear_array
    @csv_array.clear
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
