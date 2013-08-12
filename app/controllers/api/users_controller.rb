class Api::UsersController < Api::ApiController
  # GET /api/users
  def index
    users = Users.all
    authorize! :show, users
  end

  # GET /api/users/1
  def show
    user = set_user
    authorize! :show, user
  end

  # POST /api/users/1.json
  def create
    user = User.new(user_params)
    if user.save
      render action: 'show', status: :created, location: user
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/users/1.json
  def update
    user = set_user
    if user.update(user_params)
      head :no_content
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/users/1.json
  def destroy
    user = set_user
    user.destroy
    head :no_content
  end

  private
    def set_user
      User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirm)
    end
end
