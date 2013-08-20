class Api::UsersController < Api::ApiController
  skip_before_filter :json_authenticate, :only => [:show]
  load_and_authorize_resource :except => [:show]

  # GET /api/users
  def index
    render json: @users
  end

  # GET /api/users/1
  def show
    if !params[:reset_password_token].nil?
      @user = User.where(:id => params[:id], :reset_password_token => params[:reset_password_token]).first
      render json: '', status: @user.nil? ? :forbidden : :ok
    else
      authorize! :show, User
      @user = User.where(:id => params[:id])
      render json: @user
    end
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

  private
    def user_params
      params.permit User.generate_permit_params
    end
end
