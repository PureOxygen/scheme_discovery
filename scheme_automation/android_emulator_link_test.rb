
require 'rubygems'
require 'appium_lib'
require 'webdrivers'
require 'fileutils'
require 'nokogiri'

class AndroidEmulatorLinkTest

  def initialize

  end

  def execute
    session = GoogleDrive::Session.from_service_account_key("sheets.json")
    spreadsheet = session.spreadsheet_by_title("android-link-guess")
    worksheet = spreadsheet.worksheets.first
    worksheet.rows.first(100).each { |row|

      test_link(row)

      @arr << "#{row[0]},#{row[3]},#{row[4]},#{row[10]}"
      puts @arr }
    add_to_csv
  end


  def test_link(row)
    row = row[0]
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

    binding.irb

    @selenium_driver.get("https://docs.google.com/spreadsheets/d/1qDB4qtXP9HHjkiEQtCkmBi2KxGi0AUbVYQzoaG3Dv3c/edit")

    @appium_driver.find_element(:name, 'link').send_keys row
    sleep 2
    @selenium_driver.find_element(:type, 'submit').click

    binding.irb
  end
end