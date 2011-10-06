module Mnbackpack
  class ArtistsController < ApplicationController
    def index
      begin
        search = Mnbackpack::Artist.search do
          fulltext params[:search]
        end
        artists = search.results
        render json: artists
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def show
      begin
        search = Mnbackpack::Artist.search do
          fulltext params[:keyword]
        end
         artist = search.results
        render json: artist
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def search
      begin
        words = params[:keyword].split(/\s+/) 
        prefix, full_words = words.pop, words.join(' ') 
        search = Mnbackpack::Artist.search do
          adjust_solr_params do |sunspot_params|
            sunspot_params[:rows] = 8
          end
          keywords(full_words) 
          text_fields do 
            with(:name).starting_with(prefix)
            with(:sort_name).starting_with(prefix) 
          end
          facet :component_id
        end
        artists = search.results
        component = search.facet(:component_id)
        render json: component
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def albums
      begin
        albums = Mnbackpack::Artist.albums(params[:id])
        render json: albums
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def tracks
      begin
        tracks = Mnbackpack::Artist.tracks(params[:id])
        render json: tracks
      rescue => e
        render :json => {response: e.message}
      end
    end
  end
end