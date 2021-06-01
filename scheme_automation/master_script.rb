# ruby -r "./scheme_automation/master_script.rb" -e "MasterScript.new.ios_android_scheme_creator()"

# This script assumes you already have added the .ipa files to the ios-apps folder
# This script will download Android apps and do scheme discovery for both iOS and Android

class MasterScript

  def ios_android_scheme_creator
    # puts "Scraping from 'Apps To Add' spreadsheet"
    # system 'ruby -r "./scheme_automation/spreadsheet_to_csv.rb" -e "SpreadsheetToCsv.new.execute"'

    # puts "Downloading Android apps from app_data.csv..."
    # system 'ruby -r "./scheme_automation/download_apk.rb" -e "DownloadApk.new.ex()"'

    puts "Beginning Android apps scrape"
    sleep(5)
    system 'ruby -r "./scheme_automation/android_scheme_discovery.rb" -e "AndroidSchemeDiscovery.new.execute()"'

    puts "Beginning iOS apps scrape"
    sleep(5)
    system 'ruby -r "./scheme_automation/ios_scheme_discovery.rb" -e "IosSchemeDiscovery.new.execute()"'

    # puts "Making Android intent scheme guesses..."
    # sleep(5)
    # system 'ruby -r "./scheme_automation/guess_links.rb" -e "GuessLinks.new.execute()"'

    puts "Android LITE scheme guesses..."
    sleep(5)
    system 'ruby -r "./scheme_automation/guess_links_lite.rb" -e "GuessLinksLite.new.execute()"'

    # puts "Start emulator..."
    # sleep(5)
    # system 'ruby -r "./scheme_automation/android_emulator_link_test.rb" -e "AndroidEmulatorLinkTest.new.execute"'

    puts "Ended succesfully"
  end

  def test

  end
end

