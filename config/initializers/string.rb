include Rails.application.routes.url_helpers

class String
  def app_path
    ('#' + self).sub(app_templates_root_path.sub(/\s*\(.+\)$/, ''), '')
  end

  def app_file_path
    ((self.split(':')[0]).sub(/(\/)+$/, '')).sub(/(\/new)+$/, '/edit') + '.html'
  end

  def raw_path
    self.sub(/\s*\(.+\)$/, '')
  end
end
