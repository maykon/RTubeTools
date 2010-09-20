#!/usr/bin/env ruby
#
# Put this script in your PATH and download from youtube.com like this:
#   ruby RTubeToMp3.rb Link_to_Youtube
#
# You will find the downloaded musics under $HOME/Music/RTubeToMp3
#
# Created by Maykon Luís Capellari
# E-mail: maykon_capellari@yahoo.com.br

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'

STDOUT.sync = true
percent = total = 0
windows_sys = ENV['USERPROFILE']
music_folder = windows_sys.nil? ? File.join(ENV['HOME'],"/Music/RTubeToMp3") : File.join(ENV['USERPROFILE'], "\\Documents\\Music\\RTubeToMp3\\") # esta é a página em que serão salvos os capítulos
agent = Mechanize.new { |agent| agent.follow_meta_refresh = true }

exit 0 if ARGV.size == 0 # exit if no arguments
link_video = ARGV.first

#create folder if no exist
unless File.exist? music_folder
  puts "Creating #{music_folder}"
  FileUtils.mkdir_p(music_folder)
end

# index page
agent.get(link_video)

pattern = /"fmt_stream_map": ("[\w |:\/\\.?=&\,%-]+")/
url_pattern = /,5\|(http[^\|]+)(?:\|.*)?$/
name_pattern = /-\s+(.*)\s*/

link = agent.page.search("//script")[9].text.gsub(pattern).first
link = link[19...link.length]

video_name = agent.page.search("//title").text.gsub(name_pattern).first
video_name = video_name[1..video_name.length].gsub(/[\n\s]/, "")
video_name = video_name[0..video_name.length-1]

video = link.gsub(url_pattern).first
video = video.gsub(/[\\,"]/, "").gsub(/(\|\|.*)/, "")
video = video[2..video.length]

puts "################################################################################"
puts "Video: #{video_name}"
puts "Link to Youtube: #{link_video}"
puts "Link to download: #{video}"

	print "Downloading...0%"
	
	video_file = File.join(music_folder, video_name.split("/").last)
  open(video_file, 'wb') do |file|
     file.write(open(video, :content_length_proc => lambda {|t|
   	 		if t && 0 < t
        	total = t        
      	end
    		}, :progress_proc => lambda {|s|
    		  old_percent = percent
      		percent = (s * 100)/total
      		print "..#{percent}%" if percent != old_percent
    		}).read)
  end  
puts "\nDownload complete!"

music_dest = "#{music_folder}/#{video_name}.mp3"
system "ffmpeg -i #{video_file} -ab 128k -ac 2 -acodec libmp3lame -vn -y #{music_dest}"
system "rm -Rf #{video_file}"
