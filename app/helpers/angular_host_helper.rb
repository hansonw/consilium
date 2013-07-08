module AngularHostHelper
  def angularApiPath(path)
    host = ''

    case Rails.env
    when 'phonegap'
      host = 'https://consilium.scigit.com'
    when 'phonegap-staging'
      host = 'https://consilium-staging.scigit.com'
    end

    host + path
  end
end
