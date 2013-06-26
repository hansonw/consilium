class Api::ApiController < ApplicationController
  before_filter :json_authenticate

  respond_to :json

  private
    def json_authenticate
      unless @user = warden.authenticate
        render json: '', :status => :forbidden
      end
    end

end
