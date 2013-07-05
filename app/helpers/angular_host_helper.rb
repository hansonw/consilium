module AngularHostHelper
  def angularApiPath(path)
    (Rails.env.phonegap? && 'https://consilium.scigit.com' || '')  + path
  end
end
