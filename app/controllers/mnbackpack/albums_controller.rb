module Mnbackpack
  class AlbumsController < ApplicationController
    layout false
    def index
      begin
        search = Mnbackpack::Component.search do
          fulltext params[:search]
          with(:component_type_id, 2)
        end
        albums = search.results
        render json: albums
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def show
      begin
        @album = Mnbackpack::Album.get(params[:id])
        render json: @album
      rescue   => e
        render :json => {response: e.message}
      end
    end
    
    def search
      begin
        words = params[:keyword].downcase.split(/\s+/) 
        prefix, full_words = words.pop, words.join(' ') 
        search = Mnbackpack::Component.search do
          adjust_solr_params do |sunspot_params|
            sunspot_params[:rows] = 3
          end
          keywords(full_words) 
          text_fields do
            with(:title).starting_with(prefix)
          end
          with(:component_type_id, 2)
        end
        @albums = []
        results = search.results
        results.each do |result|
           @albums << { album: result, artist: result.artists.collect{ |x| x.name}.join(', ') }
        end
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @albums }
        end
      rescue => e
        render :json => {response: e.message}
      end
    end
  end
end