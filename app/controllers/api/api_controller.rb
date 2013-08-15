class Api::ApiController < ApplicationController
  before_filter :json_authenticate
  before_filter :set_current_user

  respond_to :json

  rescue_from CanCan::AccessDenied do |exception|
    render json: '', :status => :forbidden
  end

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

    def get_json(obj, attrs = {})
      return obj.map { |c| get_json(c) } if obj.is_a?(Array)
      return obj if !obj.respond_to?(:attributes)

      ret = {}
      obj.attributes.each do |key, val|
        if key == "_id"
          ret[:id] = val.to_s
        elsif val.is_a?(Moped::BSON::ObjectId)
          ret[key] = val.to_s
        elsif key == "created_at" || key == "updated_at"
          ret[key] = val.to_i
        else
          ret[key] = get_json(val)
        end
      end

      ret.merge(attrs)
    end
end
