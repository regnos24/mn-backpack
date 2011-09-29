module Mnbackpack
  class SearchController < ApplicationController
    def index
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