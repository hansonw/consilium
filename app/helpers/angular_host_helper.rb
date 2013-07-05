module AngularHostHelper
  def angularApiPath(path)
    ('https://consilium.scigit.com' if Rails.env.phonegap?) + path
  end
end
