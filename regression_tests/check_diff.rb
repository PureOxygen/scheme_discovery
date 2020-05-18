# ruby -r "./regression_tests/check_diff.rb" -e "CheckDiff.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'

class CheckDiff

  def initialize
    @apk_path = ("/Users/ericmckinney/desktop/android-regression/*new")
  end

  def execute
    locate_apk
    shuffle_files
    scrape
    get_diff
    #remove_empty_csv
  end

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

  def shuffle_files
    Dir.chdir("/Users/ericmckinney/desktop/scheme_discovery")
    FileUtils.rm_rf('./regression_tests/old_apk')

    FileUtils.mv("./regression_tests/new_apk","./regression_tests/old_apk")

    Dir.mkdir("./regression_tests/new_apk")
  end

  def scrape
    begin
      Dir.chdir(@apk_path)
      Dir.foreach(@apk_path) do |folder|
        next unless folder.include? '.apk'

        @apk_name = folder
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
      @match_name = new[0..9]

      Dir.foreach("./old_apk") do |old|
        next if old == '.' or old == '..'

        if old.include? @match_name
          FileUtils.identical?("./old_apk/#{old}","./new_apk/#{new}")
          File.open("./apk_diffs/#{new}", "wb") do |csv|
            csv.puts Diffy::Diff.new("./old_apk/#{old}","./new_apk/#{new}", :source => 'files')
          end
        end
      end
    end
  end

  def remove_empty_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests")
    Dir.foreach("./apk_diffs") do |csv|
      next if csv == '.' or csv == '..'
      binding.irb
      path = Dir.pwd + "/" + csv
      first_row = CSV.foreach(csv).take(5)
      if first_row == [[]]
        FileUtils.remove_dir(path)
      end
    end
  end
end
