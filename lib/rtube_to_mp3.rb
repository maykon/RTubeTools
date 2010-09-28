require 'youtube_tools'

class RtubeToMp3
	include YoutubeTools
	
	def searcher(search)
		Searcher.new(search)
	end
	
	def search_results(search)
		Searcher.new(search).links
	end
	
	def downloader(link)
		Downloader.new(link)
	end
	
	def converter(file, path=nil)
		Converter.new(file, path)
	end
end
