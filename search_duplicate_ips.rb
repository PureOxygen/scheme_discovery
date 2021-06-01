# ruby -r "./search_duplicate_ips.rb" -e "SearchDuplicateIps.new()"

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'CSV'
require 'zip'
require 'diffy'

class SearchDuplicateIps

  def initialize()
    @arr = []
    @mults = []
    Dir.chdir("..")
    Dir.chdir("..")

    CSV.foreach("./Downloads/twitter-Fjwt_referer_detail.txt") do |h|
        @arr << "#{h[2]}, " "#{h[3]}"
    end
    without_second = []

    b = Hash.new(0)

    @arr.each do |v|
      b[v] += 1
    end

    @prob_arr = []
    @probable_bot_hit_count = 0

    b.each do |k, v|
      if v >= 100
        @prob_arr << "#{k} appears #{v} times and might be a bot."
        puts "#{k} - appears #{v}"
        @probable_bot_hit_count += v
      end
    end
  end
end
