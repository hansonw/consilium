class Api::ApiController < ApplicationController
  before_filter :json_authenticate
  before_filter :set_current_user

  respond_to :json

  rescue_from CanCan::AccessDenied do |exception|
    render json: '', :status => :forbidden
  end

  private
    class << self
      attr_accessor :related_fields
      def render_related_fields(fields)
        @related_fields = fields
      end
    end

    def set_current_user
      ProxyCurrentUser.current_user = current_user
    end

    def verified_request?
      true
    end

    def json_authenticate
      unless @user = warden.authenticate
        render json: '', :status => :unauthorized
      end
    end

    def get_json_impl(obj, attrs = {})
      return obj.map { |c| get_json_impl(c, attrs) } if obj.is_a?(Array)

      if obj.respond_to?(:attributes)
        obj = obj.attributes
      elsif !obj.is_a?(Hash)
        return obj
      end

      ret = {}
      obj.each do |key, val|
        if key == "_id"
          ret[:id] = val.to_s
        elsif val.is_a?(Moped::BSON::ObjectId)
          ret[key] = val.to_s
        elsif key == "created_at" || key == "updated_at"
          ret[key] = val.to_i
        else
          ret[key] = get_json_impl(val)
        end
      end

      ret.merge(attrs)
    end

    def get_json(obj, attrs = {})
      return obj.map { |c| get_json(c, attrs) } if obj.is_a?(Array)

      related_attrs = {}
      if self.class.related_fields
        self.class.related_fields.each do |field, subfields|
          if obj.respond_to?(field)
            if related_obj = obj.send(field)
              related_attrs[field] = {}
              subfields.each do |subfield|
                related_attrs[field][subfield] = related_obj[subfield]
              end
            end
          end
        end
      end

      get_json_impl(obj, attrs.merge(related_attrs))
    end
end
