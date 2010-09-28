Shoes.setup do
	Gem.sources = %w[http://gems.github.com/ http://gems.rubyforge.org/ http://rubygems.org/]
	gem "YoutubeTools"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'youtube_tools'
require 'rtube_to_mp3'

class WdDownloader
	@@dw_items = []
	@@wd = nil
	
	def add(title, link, rtube)
   	dw = rtube.downloader(link)
   	create_win unless created_win?
		@@wd.app do
			stack do
				dl = nil
  	    rm_para = para title, " [", link("cancelar") { |e| dl.abort; e.parent.parent.remove; FileUtils.rm_rf(dw.full_path) }, "]", :margin => 0
        insc = inscription "Downloading...", :margin => 0;
				pg = progress :width => 1.0, :height => 12, :margin_left => 10, :margin_right => 10 + gutter
				
				dl = download dw.link_dw, :width => 560, :save => dw.full_path,
    			:progress => proc { |dl| 
    			insc.text = "Transferindo #{"%.2f" % (dl.transferred.to_f/1048576)} of #{"%.2f" % (dl.length.to_f/1048576)} Megabytes (#{dl.percent}%)"
        	pg.fraction = dl.percent * 0.01 },
      	:finish => proc { |dl| 
      		insc.text = "Download completo.";
      		rtube.converter(dw.name);
      		rm_para.text =  title, "[", link("limpar") { rm_para.parent.remove }, "]";
      	}
				@@dw_items << link
	 		end
 		end
	end
	
	def get_items
		@@dw_items
	end
	
	protected
	def create_win
		@@wd = window :title => "RTubeToMp3 Downloading...", :width => 400, :height => 300, :resizable => false do
  	end
	end
	
	def created_win?
		Shoes.APPS.each do |win|
			if win.to_s =~ /Downloading/
				return true
			end
		end
		false
	end
end

Shoes.app :title => "RTubeToMp3 Converter", :width => 600, :height => 500, :resizable => false do	
	@search_items = []
	@rtube = RtubeToMp3.new
	@wd = WdDownloader.new self
	
  @top_st = stack do
    background red, :height => 50
    flow :margin => 15 do
      caption "Pesquisar: ", :stroke => white
      @search = edit_line :width => 360
      
      button "Pesquisar", :margin_left => 5 do
      	search = @search.text      	
      	@items = @rtube.search_results search
      	show_result
      end
    end
  end
  
  @sk_search = stack do
		@result = stack :margin_left => 5, :margin_right => 5 + gutter, :height => 360, :scroll => true
		@sk_btn = stack
	end
  
  def show_result
	  @search_items = []
  	@result.clear
  	@sk_btn.clear
  	@result.append do
  		@items.each do |i|
 				flow do 
  				c = check;
  				para link("#{i[:title]}", :click => "#{i[:link]}");
	  			@search_items << [c, i[:title], i[:link]];
  			end
  		end
  	end
  	@sk_btn.append do
  		@confirm = button "Download"
			@confirm.click { confirm_download }
  	end
  end
  
  def confirm_download
  	@search_items.each do |c, t, l|
  		if c.checked?
		  	download_and_convert(t, l) unless @wd.get_items.include? l
		  end
  	end
  end
  
  def download_and_convert(title, link)
  	@wd.add title, link, @rtube
  end
end
