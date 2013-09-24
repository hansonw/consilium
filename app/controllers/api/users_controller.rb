class Api::UsersController < Api::ApiController
  # GET /api/users
  def index
    render json: @users
  end

  # GET /api/users/1.json
  def show
    if params[:id] == 'profile'
      user = @current_user
    else
      user = User.find(params[:id])
    end
    authorize! :read, user
    render json: get_json(user)
  end

  # POST /api/users/1.json
  def create
    authorize! :create, User
    @user = User.new(user_params)
    @user.brokerage = current_user.brokerage
    if @user.save
      render action: 'show', status: :created, location: user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/users/1.json
  def update
    authorize! :manage, @user

    params = user_params
    if params[:password]
      res = @user.update_with_password(user_params)
    else
      res = @user.update(user_params)
    end

    if res
      sign_in @user, :bypass => true # Don't log out after changing password
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

  private
    def user_params
      params.permit User.generate_permit_params | [:current_password, :password_confirmation]
    end
end
