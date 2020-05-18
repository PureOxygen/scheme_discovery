# TODO: The Android script will call this script. This script needs to take in an argument of the csv name and as it scans for csv's it knows which one to put the data in.

# ruby -r "./ios_scheme_discovery.rb" -e "IosSchemeDiscovery.new.execute()"

require 'rubygems'
require 'fileutils'
require 'plist'
require 'CSV'

class IosSchemeDiscovery

  def initialize
    #@csv = csv
    @ios_path = ("/Users/ericmckinney/desktop/ios-apps")
  end

  def execute
    scrape
  end

  def has_ipa?
    if @old_name.include? ".ipa"
      @ios_name = @old_name
    else
      @ios_name = "#{@old_name}.ipa"
      FileUtils.mv("#{@ios_path}/#{@old_name}","#{@ios_path}/#{@ios_name}")
    end
  end

  def has_space?
    if @ios_name.scan(/\s/).empty?
      @new_name = @ios_name
    else
      @new_name = @ios_name.gsub(/[\s]/,'_')
      FileUtils.mv("#{@ios_path}/#{@ios_name}","#{@ios_path}/#{@new_name}")
    end
  end

  def has_amp?
    if @ios_name.scan(/&/).empty?
      @new_name = @ios_name
    else
      @new_name = @ios_name.gsub(/&/,'_')
      FileUtils.mv("#{@ios_path}/#{@ios_name}","#{@ios_path}/#{@new_name}")
    end
  end

  def scrape
    begin
      Dir.foreach(@ios_path) do |f|
        next unless f.include? '.ipa'
        @old_name = f
        has_ipa?
        has_space?

        @file_name = @new_name.gsub(".ipa","")
        system("unzip #{@ios_path}/#{@new_name} -d #{@ios_path}/#{@file_name}")

        payload_path = File.join(@ios_path, @file_name, "Payload")
        plist_path = Dir["#{payload_path}/*"].first

        @csv_array = []


        plist_file = Plist.parse_xml("#{plist_path}/Info.plist")
        begin
        plist_file['CFBundleURLTypes'].each_with_index do |arr, index|
          puts "#"*100
          puts "URL Schemes: #{index += 1}"
          arr.each do |k,v|
            if k.include? "CFBundleURLSchemes"
              puts "#{k}: #{v}"
              @csv_array << @new_name
              v.each do |scheme|
                links = "iOS = '#{scheme}'"
                @csv_array << links
                @csv_array << " "
              end
            end
          end
        end
        rescue => f
          puts "Error - No schemes!!"
          end
      add_to_csv
      end
    rescue => e
      puts "#"*100
      puts "Error finding CFBundleURLTypes in  Info.plist: #{e}"
      puts "#"*100
    end
  end

  def add_to_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    @full_path = "./scheme_data/*IOS.csv"
    File.open("#{@full_path}", "a") do |f|
      @csv_array.each do |row|
        f.puts row
      end
    end
  end
end

#file_name_input = ARGV
#puts "File name input: #{file_name_input}"
#current_path = Dir.pwd
#puts Dir.pwd
#itunes_path = "../../downloads/"
#original_file_name = file_name_input.join(" ")
#updated_file_name = ''
#
#Dir.chdir(itunes_path) do
#  puts "#"*100
#  puts "Original file name: #{original_file_name}"
#  puts "Removing spaces from the file name"
#  updated_file_name = original_file_name.gsub(" ","_")
#  puts "#{original_file_name}.ipa","#{updated_file_name}.ipa"
#  FileUtils.mv("#{original_file_name}.ipa","#{updated_file_name}.ipa")
#  puts "New file name: #{updated_file_name}.ipa"
#  puts "#"*100
#  puts "Unzipping #{updated_file_name}.ipa"
#  system("unzip #{updated_file_name}.ipa -d #{updated_file_name}")
#end
#
#payload_path = File.join(itunes_path, updated_file_name, "Payload")
#plist_path = Dir["#{payload_path}/*"].first
#
#@csv_array = []
#
#begin
#  plist_file = Plist.parse_xml("#{plist_path}/Info.plist")
#
#  plist_file['CFBundleURLTypes'].each_with_index do |arr, index|
#    puts "#"*100
#    puts "URL Schemes: #{index += 1}"
#    arr.each do |k,v|
#      if k.include? "CFBundleURLSchemes"
#        puts "#{k}: #{v}"
#        links = "#{k}: #{v}"
#        @csv_array << links
#      end
#    end
#  end
#rescue => e
#  puts "#"*100
#  puts "Error finding CFBundleURLTypes in  Info.plist: #{e}"
#  puts "#"*100
#end
#
#Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
#

#end
