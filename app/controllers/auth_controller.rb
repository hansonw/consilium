##
# Note: This is distinct from the Devise controllers in that it allows authtoken-based authentication.
##

class AuthController < ApplicationController
  respond_to :json

  # POST api/auth/login
  # params: username, password
  def login
    username = params[:username]
    resource = User.where(:email => username).first

    if !resource.nil? && resource.valid_password?(params[:password])
      sign_in(resource)
      resource.ensure_authentication_token!
      render json: {
        :auth_token => resource.authentication_token,
        :expiry_ts => (Time.now + Devise.timeout_in).to_i
      }
    else
      render json: '', :status => :forbidden
    end
  end
end
