#Regression Testing:

- Split up this directory from the scheme_discovery one and make its own git repo

#download_app
- Grabs the CSV line for the google play store link and downloads the app from apkcombo
- Checks once the download is complete
- Renames the files the name of the app package
- moves the apk from downloads to android-regression/*new

#download_updated_apps.rb
 - Deletes the android-regression/old directory
 - Renames the android-regression/new to android-regression/old 
 - Scrapes update_diffs.csv and looks for any line with a '+'
 - Grabs the google play store link and downloads from apkcombo
 - Renames the download to follow convention and ensure there is no odd charectars 
 - Places the download in android-regression/new folder

#get_versions.rb
 - Scrapes google play store and gets release dates of apps from scraping the app_store_links.csv
 - Renames the new_versions.csv to old_versions.csv and creates a new_versions.csv with the new dates
 - Compares the new_versions.csv with the old_versions.csv and creates a new update_diffs.csv with a '+' in front of any line that is different
 
#scrape_apk.rb
- Extracts zip if file is a .zip
- Scrapes the apk and finds keywords
- creates csv with scheme data, titled as the apk package
- if the scheme csv is in ./csv_compare/new move it to ./csv_compare/old
- else save the scheme csv in /new

- Find difference between all android-regression/old and android-regression/new csv's



- if csv 
 

 