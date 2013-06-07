class Users::RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def show

  end

  def history
    @user = User.new
  end
end
