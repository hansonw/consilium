class Api::ApiController < ApplicationController
  before_filter :json_authenticate

  respond_to :json

  private
    def verified_request?
      true
    end

    def json_authenticate
      unless @user = warden.authenticate
        render json: '', :status => :unauthorized
      end
    end
end
