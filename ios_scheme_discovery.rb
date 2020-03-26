# ruby ./ios_scheme_discovery.rb Ancestry 11.4.1

require 'rubygems'
require 'fileutils'
require 'plist'
require 'CSV'

file_name_input = ARGV
puts "File name input: #{file_name_input}"
current_path = Dir.pwd
puts Dir.pwd
itunes_path = "../../downloads/"
original_file_name = file_name_input.join(" ")
updated_file_name = ''

Dir.chdir(itunes_path) do
  puts "#"*100
  puts "Original file name: #{original_file_name}"
  puts "Removing spaces from the file name"
  updated_file_name = original_file_name.gsub(" ","_")
  puts "#{original_file_name}.ipa","#{updated_file_name}.ipa"
  FileUtils.mv("#{original_file_name}.ipa","#{updated_file_name}.ipa")
  puts "New file name: #{updated_file_name}.ipa"
  puts "#"*100
  puts "Unzipping #{updated_file_name}.ipa"
  system("unzip #{updated_file_name}.ipa -d #{updated_file_name}")
end

payload_path = File.join(itunes_path, updated_file_name, "Payload")
plist_path = Dir["#{payload_path}/*"].first

@csv_array = []

begin
  plist_file = Plist.parse_xml("#{plist_path}/Info.plist")

  plist_file['CFBundleURLTypes'].each_with_index do |arr, index|
    puts "#"*100
    puts "URL Schemes: #{index += 1}"
    arr.each do |k,v|
      puts "#{k}: #{v}"
      links = "#{k}: #{v}"
      @csv_array << links
    end
  end
rescue => e
  puts "#"*100
  puts "Error finding CFBundleURLTypes in  Info.plist: #{e}"
  puts "#"*100
end

Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")

CSV.open("ANOTHER_ONE.csv", "wb") do |csv|
  csv << @csv_array
end
