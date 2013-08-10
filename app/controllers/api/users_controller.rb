class Api::UsersController < Api::ApiController
  load_and_authorize_resource :only => [:show, :update, :edit, :destroy]

  # GET /api/users.json
  def index
    @users = Users.all
  end

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirm)
    end
end
