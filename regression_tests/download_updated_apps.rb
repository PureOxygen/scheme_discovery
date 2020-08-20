# ruby -r "./regression_tests/download_updated_apps.rb" -e "DownloadUpdatedApps.new.new_apps()"  -- downloads only apps that have new versions
# ruby -r "./regression_tests/download_updated_apps.rb" -e "DownloadUpdatedApps.new.all_apps()"  -- downloads all apps in the app_store_links.csv

require 'webdrivers'
require 'watir'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
require 'headless'
require './regression_tests/get_versions.rb'
require './regression_tests/download_app.rb'

class DownloadUpdatedApps

  def initialize
    @version_array = []
    @app_names = []
    @download_path = "/Users/ericmckinney/downloads"
  end

  def new_apps
    move_apks_from_new_to_old
    download_updated_apps
  end

  def all_apps
    move_apks_from_new_to_old
    download_all_apps
  end

  # This moves the entire folder - to just move the app that has been updated, you need to include this in the loop.
  def move_apks_from_new_to_old
    FileUtils.rm_rf('/Users/ericmckinney/desktop/android-regression/*old/')
    FileUtils.mv('/Users/ericmckinney/desktop/android-regression/*new/', '/Users/ericmckinney/desktop/android-regression/*old/')
    FileUtils.mkdir('/Users/ericmckinney/desktop/android-regression/*new/')
  end

  def download_updated_apps
    File.open("./regression_tests/update_diffs.csv","r").readlines.each do |app|
      app = app unless app  == nil
      if app[0].include?('+')
        DownloadApp.new.execute(app)
      end
    end
  end

  def download_all_apps
    File.open("./regression_tests/app_store_links.csv","r").readlines.each do |app|
      app = app unless app  == nil
      DownloadApp.new.execute(app)
    end
  end
end