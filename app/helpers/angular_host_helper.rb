module AngularHostHelper
  def angularApiPath(path)
    host = ''

    case Rails.env
    when 'phonegap'
      host = 'https://consilium.scigit.com'
    when 'phonegap-staging'
      host = 'https://scigit-consilium-staging.herokuapp.com'
    end

    host + path
  end
end
