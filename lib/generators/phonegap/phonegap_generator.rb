class PhonegapGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  class_option :angular, :type => :boolean, :default => false, :description => "Include AngularJS single-paging"

  def copy_phonegap_file
    template "layout.html.erb", "app/views/layouts/#{file_name}.html.erb"
  end
end
