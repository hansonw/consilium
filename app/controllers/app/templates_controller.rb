class App::TemplatesController < ApplicationController
  # TODO: Come back to this later.
  #include ActionController::Caching
  #caches_page :page

  def page
    @path = params[:path]
    render :template => 'templates/' + @path, :layout => nil
  end
end
