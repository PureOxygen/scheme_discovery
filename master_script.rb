# ruby -r "./master_script.rb" -e "MasterScript.new.ex()"

# This script assumes you already have added the .ipa files to the ios-apps folder
# This script will download Android apps and do scheme discovery for both iOS and Android

class MasterScript

  def ex
    puts "Downloading Android apps from play store csv..."
    system 'ruby -r "./download_apk.rb" -e "DownloadApk.new.ex()"'
    puts "Beginning Android apps scrape"
    sleep(5)
    system 'ruby -r "./android_scheme_discovery.rb" -e "AndroidSchemeDiscovery.new.execute()"'
    puts "Beginning iOS apps scrape"
    sleep(5)
    system 'ruby -r "./ios_scheme_discovery.rb" -e "IosSchemeDiscovery.new.execute()"'
    puts "Making Android intent scheme guesses..."
    sleep(5)
    system 'ruby -r "./guess_links.rb" -e "GuessLinks.new.execute()"'
    puts "Ended succesfully"

  end
end

