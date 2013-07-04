module AngularTemplateCachingHelper
  include ActionView::Helpers

  def angularAllTemplates
    templates = {}
    FileUtils.cd Rails.root.join 'app', 'views', 'templates' do
      paths = File.join '**', '*.html.erb'
      Dir.glob(paths) do |path|
        templates[angularTemplatePath(path)] =
          angularTemplateContent(path) if angularTemplateIsValid(path)
      end
    end
    puts templates
    templates
  end

  def angularTemplateIsValid(f)
    !File.basename(f).starts_with?('_')
  end

  def angularTemplatePath(f)
    "/app/templates/#{File.path(f).sub(/\.erb/, '')}"
  end

  def angularTemplateContent(f)
    ERB.new(File.read(f), nil, '-').result
  end
end
