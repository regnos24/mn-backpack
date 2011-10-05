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
        search = Mnbackpack::Artist.search do
          fulltext params[:keyword]
        end
        artists = search.results
        render json: artists
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def albums
      begin
        albums = Mnbackpack::Artist.albums(params[:id])
        #render json: albums
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