module Mnbackpack
  class IndexController < ApplicationController
    def index
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  end
end