require 'rubygems'
require 'zip'
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
    include PhonegapTemplateCachingHelper

    puts "Exporting PhoneGap project"

    case Rails.env
    when "phonegap", "phonegap_staging"
    else
      puts "rake phonegap:export must be run under the \"phonegap\" or \"phonegap_staging\" environments"
      next
    end

    assets_path = Rails.application.assets

    project_path = Rails.root.join("phonegap")
    puts "Project path: #{project_path}"

    puts "* Clobbering project path"
    FileUtils.rm_rf project_path
    FileUtils.mkdir_p project_path

    # Export js assets
    puts "* javascript assets"
    FileUtils.mkdir_p "#{project_path}/js"
    file = File.open("#{project_path}/js/application.js", "w")
    file.write assets_path['application.js']
    file.close

    # Export css assets
    puts "* css assets"
    FileUtils.mkdir_p "#{project_path}/css"
    file = File.open("#{project_path}/css/application.css", "w")
    file.write assets_path['angular.css']
    file.close

    # Export public folder
    puts "* public folder"
    public_path = Rails.root.join("public")

    Dir.foreach public_path do |file|
      next if file == "." or file == ".."

      path = public_path + file

      if !File.symlink?(path)
        FileUtils.cp_r path, "#{project_path}/"
      end
    end

    # Export all layouts
    puts "* layouts (index.html)"
    public_source = File.expand_path('../../../../public', __FILE__)
    file = File.open("#{project_path}/index.html", "w")
    file.write phonegapRenderRoot
    file.close

    # Copy config file
    puts "* copying config.xml"
    FileUtils.cp File.dirname(__FILE__) + "/config.xml", project_path

    # Zip up the project
    puts "Zipping up project to: #{project_path}/consilium.zip"
    Zipper.zip(project_path, "#{project_path}/consilium.zip")
  end
end
