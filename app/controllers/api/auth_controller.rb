##
# Note: This is distinct from the Devise controllers in that it allows authtoken-based authentication.
##

class Api::AuthController < Api::ApiController
  skip_before_filter :json_authenticate, :only => [:login]

  # POST api/auth/login
  # params: username, password
  def login
    email = params[:email]
    resource = User.where(:email => email).first

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

  # POST api/auth/logout
  # params:
  def logout
    sign_out(current_user)
    render json: '', :status => :ok
  end
end
