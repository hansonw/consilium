require 'rubygems'
require 'zip'
require 'find'
require 'fileutils'

class Zipper
  def self.zip(dir, zip_dir)
    Zip::File.open(zip_dir, Zip::File::CREATE) do |zipfile|
      Find.find(dir) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{dir}\/(\w.*)/.match(path.to_s)
          # Skip files if they exists
          begin
            zipfile.add(dest[1],path) if dest
          rescue Zip::EntryExistsError
          end
      end
    end
  end
end

namespace :phonegap do
  desc "Export website as PhoneGap application."

  assets_path = Rails.application.assets
  project_path = Rails.root.join("phonegap", "www")

  task :export => :environment do
    include PhonegapTemplateCachingHelper

    puts "Exporting PhoneGap project"

    case Rails.env
    when "phonegap", "phonegap_staging"
    else
      puts "rake phonegap:export must be run under the \"phonegap\" or \"phonegap_staging\" environments"
      next
    end

    puts "Project path: #{project_path}"

    puts "* Clobbering project path"
    FileUtils.rm_rf project_path
    FileUtils.mkdir_p project_path

    # Export js assets
    puts "* javascript assets"
    FileUtils.mkdir_p "#{project_path}/js"
    file = File.open("#{project_path}/js/application.js", "w")
    file.write assets_path['angular.js']
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

    ### Copy needed files
    # Copy config file
    puts "* copying config.xml"
    FileUtils.cp File.dirname(__FILE__) + "/config.xml", project_path
    # Copy res folder
    puts "* copying res/"
    FileUtils.cp_r File.dirname(__FILE__) + '/res', project_path
    # Copy spec folder
    puts "* copying spec/"
    FileUtils.cp_r File.dirname(__FILE__) + '/spec', project_path

    # Delete the stray assets folder
    if Dir.exists? "#{project_path}/assets"
      puts "* Deleting stray assets folder"
      FileUtils.rm_r "#{project_path}/assets"
    end

    # Zip up the project
    puts "Zipping up project to: #{project_path}/consilium.zip"
    Zipper.zip(project_path, "#{project_path}/consilium.zip")
  end

  task :compile => :environment do
    Rake::Task["phonegap:export"].invoke
    puts "Compiling to PhoneGap application..."
    Dir.chdir project_path do
      system "phonegap local build android"
    end
    puts "Done compiling!"
  end

  task :install => :environment do
    Rake::Task["phonegap:compile"].invoke
    puts "Installing to device."
    Dir.chdir "#{project_path}/../platforms/android/bin" do
      system "adb install -r Consilium-debug.apk"
    end
  end

  task :build => :environment do
    auth_token = Rails.configuration.phonegap_config[:auth_token]
    app_id = Rails.configuration.phonegap_config[:app_id]
    url = "https://build.phonegap.com/api/v1/apps/#{app_id}?auth_token=#{auth_token}"

    Rake::Task["phonegap:export"].invoke
    puts "Sending consilium.zip to PhoneGap Build service."
    c = Curl::Easy.new url
    c.on_progress do |dl_total, dl_now, ul_total, ul_now|
      print "\r* #{ul_now}/#{ul_total}"
      true
    end
    c.on_complete do |c|
      puts ""
      puts "* Done uploading."
    end
    puts "* Starting transfer..."
    c.http_put(File.read("#{project_path}/consilium.zip"))
    status = 'pending'
    start_time = Time::now()
    begin
      c = Curl::Easy.perform url
      app = JSON.parse(c.body_str)
      status = app["status"]["android"]
      print "\r* Building... (#{(Time::now() - start_time).round(1)}s)         "
      sleep 1.seconds
    end until status != 'pending'
    puts ""
    puts "Done building with status '#{status}'. Visit https://build.phonegap.com/apps/#{app_id}/builds."
  end
end
