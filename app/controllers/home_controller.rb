class HomeController < ApplicationController
  layout 'server'

  def index
    if !user_signed_in?
      # AngularJS entry point. Angular should take over from here.
      render nil, :layout => 'angular'
    end
  end
end
