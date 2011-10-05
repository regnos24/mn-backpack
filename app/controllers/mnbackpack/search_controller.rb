module Mnbackpack
  class SearchController < ApplicationController
    def index
        artists = Mnbackpack::Artist.search do
          fulltext params[:search]
        end
        tracks = Mnbackpack::Component.search do
          fulltext params[:search]
          with(:component_type_id, 3)
        end
        albums = Mnbackpack::Component.search do
          fulltext params[:search]
          with(:component_type_id, 2)
        end
        @artists = artists.results
        @albums = albums.results
        @tracks = tracks.results
      respond_to do |format|
        format.html # index.html.erb
      end
    end
    def show
      puts params[:id]
      mn = Mnbackpack::Search.new
      begin
        response = Mnbackpack::Search.find("tracks",{:keyword => params[:id], pagesize: 20})
        render json: response
      rescue => e
        render :json => {response: e.message}
      end
    end
    
    def create
      mn = Mnbackpack::Search.new
      begin
        response = mn.request('tracks', {:keyword => params[:id], pagesize: 20})
        render json: response
      rescue => e
        render :json => {response: e.message}
      end
    end
  end
end