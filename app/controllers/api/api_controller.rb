class Api::ApiController < ApplicationController
  before_filter :json_authenticate
  before_filter :set_current_user

  respond_to :json

  private
    def set_current_user
      ProxyCurrentUser.subclasses.each do |proxy|
        # XXX: This can potentially cause memory leaks on Thin and Puma.
        proxy.current_user = current_user
      end
    end

    def verified_request?
      true
    end

    def json_authenticate
      unless @user = warden.authenticate
        render json: '', :status => :unauthorized
      end
    end
end
