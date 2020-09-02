# ruby -r "./regression_tests/get_difference.rb" -e "GetDifference.new.execute()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'

class GetDifference

  def initialize
    @old_apps = ("/Users/ericmckinney/desktop/scheme_discovery/regression_tests/csv_compare/old")
    @new_apps = ("/Users/ericmckinney/desktop/scheme_discovery/regression_tests/csv_compare/new")
    @apk_diffs = ("/Users/ericmckinney/Desktop/scheme_discovery/regression_tests/apk_diffs")
  end

  def execute
    clear_current_diffs
    new_csv_loop
  end

  def clear_current_diffs
    FileUtils.rm_rf(@apk_diffs)
    sleep(5)
    FileUtils.mkdir(@apk_diffs)
  end

  # TODO: The new idea is going to be only downloading the app if it has a + sign / is new
  # Because of this, we will download the updated app seperately, then scrape all of the apps in /new and create CSV's for them
  # Once all of the apps csv's have been scraped and are added to '/new' I just need to compare them, and put the results in csv_compare as it's own spreadsheet
  # Again - that's all i have to do: Loop through the all the csv's in '/new' in csv_compare, and compare it with the same one in '/old'  -- SO CLOSE!!!

  def new_csv_loop
    Dir.chdir(@new_apps)
    Dir.foreach(@new_apps) do |new_csv|
      next unless new_csv.include? '.csv'
      @csv_name = "#{new_csv}"
      Dir.foreach(@old_apps) do |old_csv|
        next unless old_csv.include? '.csv'
        new_path = "#{@new_apps}/#{new_csv}"
        old_path = "#{@old_apps}/#{old_csv}"
        binding.irb
        if FileUtils.identical?(old_csv,new_csv)
          binding.irb
          get_difference(new_path, old_path)
        else
          puts "This is a new app - there is no older version to compare it to"
        end
      end
    end
  end

  def get_difference(new_csv, old_csv)
    Dir.chdir(@apk_diffs)
    File.open(@apk_diffs + '/' + new_csv, "w") do |csv|
      csv.puts Diffy::Diff.new(new_csv, old_csv, :source => 'files', :allow_empty_string => false)
      binding.irb
    end
  end
end
