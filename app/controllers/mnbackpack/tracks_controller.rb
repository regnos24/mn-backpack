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
  end
end