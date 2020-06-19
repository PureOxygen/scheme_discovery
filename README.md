The scripts in this folder should all work independently, but the intention is to
get them working together to achieve broader steps in the scheme discovery process.

<h2>android_scheme_discovery.rb</h2>

-Used to scrape Android Manifest files and return keywords used in schemes

<h2>download_apk.rb</h2>
-After pasting a set of Google Play Store app links into `play_store_link.csv`, this 
script will scrape `apkpure.com` and download the apk file if it is available.

-This typically only works about 75% of the time, the rest will still have to be
hand downloaded.

<h2>scheme_discovery</h2>
-Used to scrape iOS .ipa app files and return keywords used in schemes. 


In order to run the scripts, you must download and install apktool.

The docs for apktool are bad. Use this: http://macappstore.org/apktool/

You can find the official website here: https://ibotpeaches.github.io/Apktool/

 