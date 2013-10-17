class HomeController < ApplicationController
  def index
    render :layout => 'server'
  end

  def unsupported
    render :layout => nil
  end

  def app
    render 'index', :layout => 'angular'
  end
end
