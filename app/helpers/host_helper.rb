module HostHelper
  def angularApiPath(path)
    site_host(true) + path
  end

  def site_host(api_request = false)
    case Rails.env
    when 'production', 'phonegap'
      host = 'https://consilium.scigit.com'
    when 'staging', 'phonegap_staging'
      host = 'https://consilium-staging.scigit.com'
    when 'development', 'testing'
      host = api_request ? '' : 'http://localhost:3000'
    end
  end
end
