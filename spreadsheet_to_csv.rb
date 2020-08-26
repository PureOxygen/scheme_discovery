# ruby -r "./spreadsheet_to_csv.rb" -e "SpreadsheetToCsv.new.execute"

require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "google_drive"

class SpreadsheetToCsv

  def initialize
    @arr = []
  end

  def execute
    session = GoogleDrive::Session.from_service_account_key("sheets.json")
    spreadsheet = session.spreadsheet_by_title("test sheet 1")
    worksheet = spreadsheet.worksheets.first
    worksheet.rows.first(100).each { |row|
      @arr << "#{row[0]}, #{row[3]}, #{row[4]}, #{row[10]}"
      puts @arr }
    binding.irb
  end
end