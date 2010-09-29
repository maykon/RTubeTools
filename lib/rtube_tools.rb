require 'youtube_tools'

class RtubeTools
	include YoutubeTools
	FOLDER_PATH = File.join(ENV['HOME'],"/Musica/RTubeToMp3") # Folder Path from musics
	
	def searcher(search, options={})
		Searcher.new(search, options)
	end
	
	def search_results(search, options={})
		Searcher.new(search, options).links
	end
	
	def downloader(link, options={})
		Downloader.new(link, options)
	end
	
	def converter(file, path=nil)
		Converter.new(file, path)
	end
end
