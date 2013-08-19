module HostHelper
  def angularApiPath(path)
    site_host + path
  end

  def site_host
    case Rails.env
    when 'production', 'phonegap'
      host = 'https://consilium.scigit.com'
    when 'staging', 'phonegap_staging'
      host = 'https://consilium-staging.scigit.com'
    when 'development', 'testing'
      host = 'https://localhost:3000'
    end
  end
end
