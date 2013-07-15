module AngularTemplateCachingHelper
  class AngularTemplateRenderer < ActionController::Base
    # XXX: HACK HACK HACK. We shouldn't have to do this.
    # Without it, anything in this helper is undefined. We will have to manually
    # add each helper that we use anywhere to this list.
    require "#{Rails.root}/app/helpers/form_helper"
    helper FormHelper

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
    AngularTemplateRenderer.new.render_to_string('layouts/angular.html.erb')
  end
end
