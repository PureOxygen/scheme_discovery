# ruby -r "./scheme_automation/spreadsheet_to_csv.rb" -e "SpreadsheetToCsv.new.execute"

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
    delete_old_scheme_data
    get_data
    add_to_csv
  end

  def delete_old_scheme_data
    Dir::foreach('scheme_data') do |f|
      if f == '*IOS.csv' || f == '.' || f == '..' || f == '.DS_Store'
        next
      else
        file = "scheme_data/#{f}"
        File.delete(file)
      end
    end
  end

  def get_data
    session = GoogleDrive::Session.from_service_account_key("sheets.json")
    spreadsheet = session.spreadsheet_by_title("Apps To Add")
    worksheet = spreadsheet.worksheets.first
    worksheet.rows.first(100).each { |row|
      next if row.include? "App Name"
      @arr << "#{row[0]},#{row[3]},#{row[4]},#{row[10]}"
      puts @arr }
    add_to_csv
  end

  def add_to_csv
    Dir.chdir("/Users/ericmckinney/Desktop/scheme_discovery")
    File.open("app_data.csv", "wb") do |f|
      @arr.each do |row|
        f.puts row
      end
    end
  end
end