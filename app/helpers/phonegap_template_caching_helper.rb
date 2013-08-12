module PhonegapTemplateCachingHelper
  class PhonegapTemplateRenderer < ActionController::Base
  end

  def phonegapAllTemplates
    templates = {}
    FileUtils.cd Rails.root.join 'app', 'views', 'templates' do
      paths = File.join '**', '*.html.erb'
      Dir.glob(paths) do |path|
        templates[phonegapTemplatePath(path)] =
          phonegapTemplateContent(path) if phonegapTemplateIsValid(path)
      end
    end
    templates
  end

  private
    def phonegapTemplateIsValid(f)
      !File.basename(f).starts_with?('_')
    end

    def phonegapTemplatePath(f)
      "app/templates/#{File.path(f).sub(/\.erb/, '')}"
    end

    def phonegapTemplateContent(f)
      PhonegapTemplateRenderer.new.render_to_string('templates/' + f)
    end

    def phonegapRenderRoot
      PhonegapTemplateRenderer.new.render_to_string('layouts/angular.html.erb')
    end
end
