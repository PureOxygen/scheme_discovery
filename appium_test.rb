# This is just a shell, I need to decide how I want the phone to get the schemes
# This should run a new instance with each app/csv
# Have one method that loops through the csv's then calls another method to try the links on that csv - that way we can loop through the entire directory AND individual csv's if needed
#
# ruby -r "./appium_test.rb" -e "AppiumTest.new.execute()"

require 'rubygems'
require 'appium_lib'
require 'webdrivers'
require 'fileutils'
require 'nokogiri'

require 'rubygems'
require 'appium_lib'

# Configure call to Appium Server
# More information is available at http://appium.io/slate/en/master/?ruby#appium-server-capabilities.
desired_caps = {
  caps:  {
    platformName:  'Android',
    platformVersion: '11.0',
    deviceName:    'Pixel_3_API_30',
    browserName:   'Chrome',
  }
}

# Create a new Appium specific driver with helpers availabe
@appium_driver = Appium::Driver.new(desired_caps)

# Standard Selenium driver without any Appium methods.
# Need to convert to Selenium driver to make "get" call
# since Appium doesn't support "get" method.
@selenium_driver = @appium_driver.start_driver

# Promote appium method to class instance methods
# Without promoting we would need to make all calls with the @appium_driver, example:
#   @appium_driver.find_element(:id, 'lst-ib')
# After promoting to a class instance method we can the method directly, example:
#   find_element(:id, 'lst-ib')
Appium.promote_appium_methods Object

binding.irb

# Open web page
@selenium_driver.get("http://www.google.com/")

# Extra time to allow webpage to load
sleep(5)

# Find Search Box element, click on it, type in Search Query
element = find_element(:id, 'lst-ib')
element.click
element.send_keys 'Steven Miller Dentedghost Appium'

# Extra pause for demostration
sleep(2)

# Find Search Button element, click on it
element = find_element(:id, 'tsbb')
element.click

# Extra time to allow webpage to load
sleep (5)

# Properly close down the driver
driver_quit

# Print test pass success message
puts "Tests Succeeded"


