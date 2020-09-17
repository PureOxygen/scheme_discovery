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

  def new_csv_loop
    Dir.chdir(@new_apps)
    Dir.foreach(@new_apps) do |new_csv|
      next unless new_csv.include? '.csv'
      @csv_name = "#{new_csv}"
      Dir.foreach(@old_apps) do |old_csv|
        next unless old_csv.include? new_csv.split('.')[0]
        new_path = "#{@new_apps}/#{new_csv}"
        old_path = "#{@old_apps}/#{old_csv}"
        get_difference(new_path, old_path)
      end
    end
  end

  def get_difference(new_csv, old_csv)
    Dir.chdir(@apk_diffs)
    File.open(@apk_diffs + "/" + @csv_name, "w") do |csv|
      csv.puts Diffy::Diff.new(new_csv, old_csv, :source => 'files', :allow_empty_string => false)
    end
  end
end
