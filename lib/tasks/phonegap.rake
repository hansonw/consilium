namespace :phonegap do
  desc "Export website as PhoneGap application."
  task :export => :environment do
    include AngularTemplateCachingHelper

    puts "Exporting PhoneGap project"

    case Rails.env
    when 'phonegap', 'phonegap-staging'
    else
      puts 'rake phonegap:export must be run under the "phonegap" or "phonegap-staging" environments'
      next
    end

    assetsPath = Rails.application.assets

    project_path = Rails.root.join('phonegap')
    FileUtils.mkdir_p project_path

    # Export js assets
    puts '* javascript assets'
    FileUtils.mkdir_p "#{project_path}/js"
    file = File.open("#{project_path}/js/application.js", "w")
    file.write assetsPath['application.js']
    file.close

    # Export css assets
    puts '* css assets'
    FileUtils.mkdir_p "#{project_path}/css"
    file = File.open("#{project_path}/css/application.css", "w")
    file.write assetsPath['angular.css']
    file.close

    # Export images
    puts '* images folder'
    #FileUtils.mkdir_p "#{project_path}/assets"
    FileUtils.mkdir_p "#{project_path}/images"
    #other_paths = Rails.configuration.assets.paths.select {|x| x =~ /\/fonts$|\/images$/}
    other_paths = Rails.configuration.assets.paths.select {|x| x.to_s.ends_with?('images') }
    other_paths.each do |path|
      files = Dir.glob("#{path}/*.*")
      files.each do |file|
        FileUtils.cp file, "#{project_path}/images/"
      end
    end

    # Export fonts folder
    puts '* fonts folder'
    FileUtils.mkdir_p "#{project_path}/font"
    other_paths = Rails.configuration.assets.paths.select {|x| x.to_s.ends_with?('font') }
    other_paths.each do |path|
      files = Dir.glob("#{path}/*.*")
      files.each do |file|
        FileUtils.cp file, "#{project_path}/font/"
      end
    end

    # Export all layouts
    puts '* layouts (index.html)'
    public_source = File.expand_path('../../../../public', __FILE__)
    file = File.open("#{project_path}/index.html", "w")
    file.write angularRenderRoot
    file.close

    # Fix relative paths and configure API server
    #css_file_path = "#{project_path}/css/application.css"
    #css_file = File.read(css_file_path)
    #new_css_file = css_file.gsub(/\/assets/, '../assets')
    #file = File.open(css_file_path, "w")
    #file.puts new_css_file
    #file.close
    #js_file_path = "#{project_path}/js/application.js"
    #js_file = File.read(js_file_path)
    #new_js_file = js_file.gsub(/src=\\"\//, 'src=\"')
    #if @api_server.blank?
    #  puts "Warning: No API server is specified for this app"
    #else
    #  if new_js_file =~ /href=\\"\//
    #    puts "Relative paths found. Making absolute to reference API: #{@api_server}"
    #    new_js_file.gsub!(/href=\\"\//, 'href=\"'+@api_server+'/')
    #  end
    #end
    #file = File.open(js_file_path, "w")
    #file.puts new_js_file
    #file.close
  end
end
