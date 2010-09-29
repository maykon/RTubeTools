Shoes.setup do
	Gem.sources = %w[http://gems.github.com/ http://gems.rubyforge.org/ http://rubygems.org/]
	gem "YoutubeTools >= 0.0.3"
	gem "hpricot"
end

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'youtube_tools'
require 'rtube_tools'

class WdDownloader
	@@dw_items = []
	@@wd = nil
	
	def add(title, link, rtube, format)
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
      		rtube.converter(dw.name, format) if format != :none
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

Shoes.app :title => "RTubeTools", :width => 650, :height => 500, :resizable => false do	
	ORDERED = { "Relevância" => 0, "Publicado" => 1, "Total visto" => 2, "Classificação" => 3 }

	@order = 0
	@start = 0
	@max = 10
	@format = :none
	@search_items = []
	@rtube = RtubeTools.new
	@wd = WdDownloader.new self
	@normal_search = false
	
  @top_st = stack do
    background red
    flow :margin => 15 do
      caption "Pesquisar: ", :stroke => white
      @search = edit_line :width => 300
      
      button "Pesquisar", :margin_left => 5 do
      	search = @search.text
      	@items = @rtube.search_results(search, :order_by => @order, :start_index => @start, :max_results => @max)
      	show_result
      end
      
      @modo = para link("Avançado", :stroke => white) { search_advanced }, :margin_left => 5
    end
    @search_advanced = stack
  end
  
  @sk_search = stack do
		@result = stack :margin_left => 5, :margin_right => 5 + gutter, :height => 360, :scroll => true
		@sk_btn = stack
	end
	
	def search_advanced
		unless @normal_search			
			@search_advanced.append do
				flow {
					para "Ordenar: ", :stroke => white
					@order_list = list_box :items => ["Relevância", "Publicado", "Total visto", "Classificação"], :choose => "Relevância", :width => 140
					@order_list.change { |e| @order = ORDERED[e.text]; }
					
					para "Início", :stroke => white, :margin_left => 5
					@start_edit = edit_line :width => 50, :margin_left => 5
					@start_edit.change { |e| set_start(e.text); }
					
					para "Nr. Máximo", :stroke => white, :margin_left => 5
					@max_edit = edit_line :width => 50, :margin_left => 5
					@max_edit.change { |e| set_max(e.text); }
					
					para "Converter:", :stroke => white, :margin_left => 5
					@conv_list = list_box :items => [:none, :avi, :mp3, :mp4, :mpg], :width => 80, :choose => :none, :margin_left => 5
					@conv_list.change { |e| @format = e.text }
				}
			end
			@modo.text = link("Normal", :stroke => white) { search_advanced }
			@normal_search = true
		else
			@search_advanced.clear
			@order = @start = 0
			@max = 10
			@format = :none
			@modo.text = link("Avançado", :stroke => white) { search_advanced }
			@normal_search = false
		end
	end
	
	def set_start(text)
		if check_number(text)
			n = text.to_i
			@start = n if n > 0 && n <= 9999
		end
	end
	
	def set_max(text)
		if check_number(text)
			n = text.to_i
			@max = n if n > 0 && n <= 50
		end
	end
	
	def check_number(text)
		return true unless text.gsub(/(\d)+/).first.nil?
		false
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
  	@wd.add title, link, @rtube, @format
  end
end
