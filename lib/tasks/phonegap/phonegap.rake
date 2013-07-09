require 'rubygems'
require 'zip/zip'
require 'find'
require 'fileutils'

class Zipper
  def self.zip(dir, zip_dir)
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE) do |zipfile|
      Find.find(dir) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{dir}\/(\w.*)/.match(path.to_s)
          # Skip files if they exists
          begin
            zipfile.add(dest[1],path) if dest
          rescue Zip::ZipEntryExistsError
          end
      end
    end
  end
end

namespace :phonegap do
  desc "Export website as PhoneGap application."
  task :export => :environment do
    include AngularTemplateCachingHelper

    puts "Exporting PhoneGap project"

    case Rails.env
    when "phonegap", "phonegap_staging"
    else
      puts "rake phonegap:export must be run under the \"phonegap\" or \"phonegap_staging\" environments"
      next
    end

    assetsPath = Rails.application.assets

    project_path = Rails.root.join("phonegap")
    puts "Project path: #{project_path}"

    puts "* Clobbering project path"
    FileUtils.rm_rf project_path
    FileUtils.mkdir_p project_path

    # Export js assets
    puts "* javascript assets"
    FileUtils.mkdir_p "#{project_path}/js"
    file = File.open("#{project_path}/js/application.js", "w")
    file.write assetsPath['application.js']
    file.close

    # Export css assets
    puts "* css assets"
    FileUtils.mkdir_p "#{project_path}/css"
    file = File.open("#{project_path}/css/application.css", "w")
    file.write assetsPath['angular.css']
    file.close

    # Export images
    puts "* images folder"
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
    puts "* fonts folder"
    FileUtils.mkdir_p "#{project_path}/font"
    other_paths = Rails.configuration.assets.paths.select {|x| x.to_s.ends_with?('font') }
    other_paths.each do |path|
      files = Dir.glob("#{path}/*.*")
      files.each do |file|
        FileUtils.cp file, "#{project_path}/font/"
      end
    end

    # Export all layouts
    puts "* layouts (index.html)"
    public_source = File.expand_path('../../../../public', __FILE__)
    file = File.open("#{project_path}/index.html", "w")
    file.write angularRenderRoot
    file.close

    # Copy config file
    puts "* copying config.xml"
    FileUtils.cp File.dirname(__FILE__) + "/config.xml", project_path

    # Zip up the project
    puts "Zipping up project to: #{project_path}/consilium.zip"
    Zipper.zip(project_path, "#{project_path}/consilium.zip")

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
