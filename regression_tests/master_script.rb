# ruby -r "./regression_tests/master_script.rb" -e "MasterScript.new.execute()"

class MasterScript

  def execute
    puts "Get latest update information"
    system 'ruby -r "./regression_tests/get_versions.rb" -e "GetVersions.new.execute()"'

    puts "Download only the apps that have been updated"
    system 'ruby -r "./regression_tests/download_updated_apps.rb" -e "DownloadUpdatedApps.new.new_apps()"'

    puts "Scraping app for schemes..."
    system 'ruby -r "./regression_tests/scrape_apk.rb" -e "ScrapeApk.new.execute()"'

    puts "Getting the difference..."
    system 'ruby -r "./regression_tests/get_difference.rb" -e "GetDifference.new.execute()"'
  end

  def lite

  end
end