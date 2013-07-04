module AngularTemplateCachingHelper
  class AngularTemplateRenderer < AbstractController::Base
    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Layouts
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include ActionController::UrlFor
    include Rails.application.routes.url_helpers

    helper ApplicationHelper
    helper ClientsHelper

    def initialize(*args)
      super()
      lookup_context.view_paths = Rails.root.join('app', 'views')
    end

    def protect_against_forgery?
      false
    end

    def flash
      {}
    end

    def params
      {}
    end

    self.asset_host = ActionController::Base.asset_host
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
end
