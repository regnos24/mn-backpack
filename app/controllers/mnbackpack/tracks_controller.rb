module Mnbackpack
  class TracksController < ApplicationController
    layout false
    def index
      begin
        search = Mnbackpack::Component.search do
          fulltext params[:search]
          with(:component_type_id, 3)
        end
        tracks = search.results
        render json: tracks
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def show
      begin
        @track = Mnbackpack::Track.get(params[:id])
        render json: @track
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
          with(:component_type_id, 3)
        end
        @tracks = []
        results = search.results
        results.each do |result|
           @tracks << { track: result, album: Mnbackpack::Component.track_album(result.id).first, artist:result.artists.collect{ |x| x.name}.join(', ') }
        end
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @tracks }
        end
      rescue => e
        render :json => {response: e.message}
      end
    end
    
  end
end