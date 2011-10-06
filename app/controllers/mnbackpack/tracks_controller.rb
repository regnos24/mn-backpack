module Mnbackpack
  class TracksController < ApplicationController
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
    
    def search
      begin
        words = params[:keyword].split(/\s+/) 
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
        tracks = search.results
        render json: tracks
      rescue => e
        render :json => {response: e.message}
      end
    end
  end
end