module Mnbackpack
  class AlbumsController < ApplicationController
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
  end
end