require 'rubygems'
require 'open-uri'

percent = 0
total = 0

PATH = File.join(ENV['HOME'],"/Music")
img = "http://img.vivaolinux.com.br/imagens/dicas/comunidade/ruby.png"
name = "ruby.jpg"
video_file = File.join(PATH, name)

print "Downloading...0%"

open(video_file, 'wb') do |file|
  file.write(open(img, :content_length_proc => lambda {|t|
   	 if t && 0 < t
        total = t        
      end
    },
    :progress_proc => lambda {|s|
      percent = (s * 100)/total
      print "..#{percent}%"
    }).read)
end
puts "Download completed..."
