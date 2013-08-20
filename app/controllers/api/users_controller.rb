class Api::UsersController < Api::ApiController
  skip_before_filter :json_authenticate, :only => [:reset_password_valid, :reset_password]
  load_and_authorize_resource :except => [:reset_password_valid, :reset_password]

  # GET /api/users
  def index
    render json: @users
  end

  # GET /api/users/1.json
  def show
    render json: @user
  end

  # POST /api/users/1.json
  def create
    authorize! :create, User
    @user = User.new(user_params)
    if @user.save
      render action: 'show', status: :created, location: user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/users/1.json
  def update
    if @user.update(user_params)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/users/1.json
  def destroy
    @user.destroy
    head :no_content
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
      params.permit User.generate_permit_params
    end
end
