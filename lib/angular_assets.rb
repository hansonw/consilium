module AngularAssets
  def self.templateUrl(path)
    basePath = 'angular/templates/'
    ActionController::Base.helpers.asset_path(basePath + path)
  end
end
