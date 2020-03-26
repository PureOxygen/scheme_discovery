#ruby ./android_scheme_discovery.rb Amazon Shopping Search Find Ship and Save_v20.5.0.100_apkpure.com.apk

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'

file_name_in = ARGV

apk_files_path = ("/Users/ericmckinney/Downloads/")
Dir.chdir(apk_files_path)

if file_name_in.size > 1
  old_name = file_name_in.join(" ")
  new_name = old_name.gsub(" ", "_")
  FileUtils.mv("#{old_name}","#{new_name}")
  file_name_input = new_name
else
  file_name_input = file_name_in[0]
end

puts "File name input: #{file_name_input}"

#RUN APK TOOL

system "apktool d #{apk_files_path}#{file_name_input}"

manifest_file_name = file_name_input.gsub(".apk","")

path_and_name = "#{apk_files_path}#{manifest_file_name}"
puts path_and_name

Dir.chdir(manifest_file_name)


doc = Nokogiri.parse(File.read("AndroidManifest.xml"))
filterData = "intent-filter.data."

@csv_array = []

package_name = doc.search("manifest").each do |i|
  i.each do |att_name, att_value|
    links = {"#{att_name}" => att_value}
    puts "#"*100
    puts links
    @csv_array << links
  end
end

android_keywords = doc.search("data").each do |i|
  i.each do |att_name, att_value|
    links = {"#{att_name}" => att_value}
    puts "#"*100
    puts links
    @csv_array << links
  end
end


Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")

CSV.open("ANOTHER_ONE.csv", "wb") do |csv|
  csv << @csv_array
end
