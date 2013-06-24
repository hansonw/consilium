class HomeController < ApplicationController
  #before_filter :authenticate_user!

  def index
    render :layout => 'angular'
  end
end
