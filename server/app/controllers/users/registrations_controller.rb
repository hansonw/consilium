class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @updated = params[:updated]
    super
  end

  def show

  end

  def history
    @user = User.new
  end

  def history2
    @user = User.new
    @updated = params[:updated]
  end
end
