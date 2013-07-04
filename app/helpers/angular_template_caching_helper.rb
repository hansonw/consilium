module AngularTemplateCachingHelper
  class AngularTemplateRenderer < ActionController::Base
    # XXX: HACK HACK HACK. We shouldn't have to do this.
    require "#{Rails.root}/app/helpers/clients_helper"
    helper ClientsHelper

    include ActionView::Helpers::AssetTagHelper

    def protect_against_forgery?
      false
    end
  end

  def angularAllTemplates
    templates = {}
    FileUtils.cd Rails.root.join 'app', 'views', 'templates' do
      paths = File.join '**', '*.html.erb'
      Dir.glob(paths) do |path|
        templates[angularTemplatePath(path)] =
          angularTemplateContent(path) if angularTemplateIsValid(path)
      end
    end
    templates
  end

  def angularTemplateIsValid(f)
    !File.basename(f).starts_with?('_')
  end

  def angularTemplatePath(f)
    "app/templates/#{File.path(f).sub(/\.erb/, '')}"
  end

  def angularTemplateContent(f)
    AngularTemplateRenderer.new.render_to_string('templates/' + f)
  end

  def angularRenderRoot
    #app = Consilium::Application
    #app.routes.default_url_options = { :host => 'xxx.com' }
    #controller = AngularTemplateRenderer.new
    #view = ActionView::Base.new(Rails.root.join('app', 'views'), {}, controller)
    #view.class_eval do
    #  include ApplicationHelper
    #  include ClientsHelper
    #  include app.routes.url_helpers
    #end
    #view.render(:template => 'layouts/angular.html.erb')

    AngularTemplateRenderer.new.render_to_string('layouts/angular.html.erb')
  end
end
