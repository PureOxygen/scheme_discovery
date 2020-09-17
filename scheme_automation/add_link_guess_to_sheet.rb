# ruby -r "./scheme_automation/add_link_guess_to_sheet.rb" -e "AddLinkGuessToSheet.new.execute"

require 'rubygems'
require 'fileutils'
require 'CSV'
require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "google_drive"
require "./scheme_automation/android_emulator_link_test.rb"

class AddLinkGuessToSheet

  def initialize
    @arr = []
  end

  def execute
    add_intent_schemes_to_array
  end

  def add_intent_schemes_to_array
    Dir.foreach("./scheme_data") do |f|

      @csv_name = f
      next if f == '.' or f == '..' or f.include? '*IOS' or f.include? 'DS_Store'
      CSV.foreach("./scheme_data/#{f}") do |row|
        next unless row[0].to_s.include?('intent')
        @arr << "#{row[0]}"
      end

      add_array_to_google_sheet

      AndroidEmulatorLinkTest.new.execute()
    end
  end


  def add_array_to_google_sheet
    session = GoogleDrive::Session.from_service_account_key("./sheets.json")
    spreadsheet = session.spreadsheet_by_title("android-link-guess")

    worksheet = spreadsheet.worksheets.first

    # worksheet.clear()
    worksheet.delete_rows(1,1000)
    worksheet.insert_rows(worksheet.num_rows + 1000, [[""]])

    @arr.each do |y|
      worksheet.insert_rows(worksheet.num_rows + 1, [["#{y}"]])
    end
    worksheet.save
  end
end

#CHECK FILE PERMISSIONS WITHIN GOOGLE DRIVE
