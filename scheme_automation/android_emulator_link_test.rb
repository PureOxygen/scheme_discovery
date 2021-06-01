# ruby -r "./scheme_automation/android_emulator_link_test.rb" -e "AndroidEmulatorLinkTest.new.execute"

require 'rubygems'
require 'appium_lib'
require 'webdrivers'
require 'fileutils'
require 'nokogiri'
require 'CSV'


class AndroidEmulatorLinkTest

  def initialize
    @arr = []
  end

  # def execute
  #   session = GoogleDrive::Session.from_service_account_key("sheets.json")
  #   spreadsheet = session.spreadsheet_by_title("android-link-guess")
  #   worksheet = spreadsheet.worksheets.first
  #   worksheet.rows.first(100).each { |row|
  #
  #     test_link(row)
  #
  #     @arr << "#{row[0]},#{row[3]},#{row[4]},#{row[10]}"
  #     puts @arr }
  #   add_to_csv
  # end

  def execute
    Dir.chdir("/Users/ericmckinney/desktop/scheme_discovery/")

    Dir.foreach("./scheme_data") do |f|

      @csv_name = f
      next if f == '.' or f == '..' or f.include? '*IOS' or f.include? 'DS_Store'

      CSV.foreach("./scheme_data/#{f}") do |row|
        next unless row[0].to_s.include?('intent://')

        @arr << "#{row[0]}"
        test_link(row[0])

      end
    end
  end

  def test_link(row)
    desired_caps = {
      caps:  {
        platformName:  'Android',
        platformVersion: '11.0',
        deviceName:    'Pixel_3_API_30',
        browserName:   'Chrome',
      }
    }

    @appium_driver = Appium::Driver.new(desired_caps)
    @selenium_driver = @appium_driver.start_driver
    Appium.promote_appium_methods Object

    @selenium_driver.get("https://halgatewood.com/deeplink/")

    sleep 2

    @selenium_driver.find_element(css: "body > div.wrap > form > input[type=url]").send_keys row
    sleep 3
    @selenium_driver.find_element(:css, "body > div.wrap > form > div > input[type=submit]").click
    sleep 5

    @selenium_driver.find_element(:xpath, "/html/body/div[1]/div/div[1]/a").click

    #     @selenium_driver.find_element(css: "body > div.wrap > div > div.click > a").click
    #/html/body/div[1]/div/div[1]/a

    sleep 10

    # TODO: if 'install' is present in button >> click - wait for download ? else ? end

  end
end