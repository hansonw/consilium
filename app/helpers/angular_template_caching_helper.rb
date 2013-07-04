module AngularTemplateCachingHelper
  class AngularTemplateRenderer < ActionView::Base
    include Rails.application.routes.url_helpers
    include ActionView::Helpers
    include ActionDispatch::Routing

    def default_url_options
      {host: 'consilium.scigit.com'}
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
    "/app/templates/#{File.path(f).sub(/\.erb/, '')}"
  end

  def angularTemplateContent(f)
    #ERB.new(File.read(f), nil, '-').result
    renderer = AngularTemplateRenderer.new(Rails.root.join('app', 'views'))
    renderer.render(template: File.path('templates/' + f))
  end
end
