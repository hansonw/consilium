##
# Note: This is distinct from the Devise controllers in that it allows authtoken-based authentication.
##

class Api::AuthController < Api::ApiController
  skip_before_filter :json_authenticate, :only => [:login, :sign_up, :reset_password_valid, :reset_password]

  # POST api/auth/login
  # params: username, password
  def login
    if params[:email]
      email = params[:email]
      resource = User.where(:email => email).first
      if !resource.nil? && resource.valid_password?(params[:password])
        sign_in(resource)
      else
        return head :forbidden
      end
    elsif current_user
      resource = current_user
    else
      return head :bad_request
    end

    resource.ensure_authentication_token!
    render json: {
      :id => resource.id.to_s,
      :email => resource.email,
      :auth_token => resource.authentication_token,
      :permissions => resource.permissions,
      :expiry_ts => (Time.now + Devise.timeout_in).to_i
    }
  end

  # POST api/auth/sign_up
  # params: name, email, password
  def sign_up
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST api/auth/logout
  # params:
  def logout
    sign_out(current_user)
    render json: '', :status => :ok
  end

  # GET /api/users/1.json/reset_password
  # Note that here and in reset_password, we must be careful not to provide
  # information as to whether or not a user actually exists. Thus, if either
  # the user doesn't exist, or the reset token was wrong, we must provide
  # the same status (forbidden).
  def reset_password_valid
    @user = User.where(:id => params[:id], :reset_password_token => params[:reset_password_token]).first
    render json: '', status: @user.nil? ? :forbidden : :ok
  end

  # PUT /api/users/1.json/reset_password
  def reset_password
    @user = User.where(:id => params[:id], :reset_password_token => params[:reset_password_token]).first
    if @user.nil?
      render json: '', status: :forbidden
      return
    end

    @user.update_attributes({:password => params[:password], :password_confirmation => params[:password], :reset_password_token => nil})
    if @user.save
      render json: '', status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.permit [:name, :email, :password, :password_confirmation]
    end
end
