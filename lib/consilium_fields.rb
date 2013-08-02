module ConsiliumFields
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def expand_fields(node = self::FIELDS)
      fields = node.map do |field|
        if field[:type].is_a?(Array) && !field[:id].ends_with?('s')
          field[:type]
        else
          field
        end
      end
      return fields.flatten
    end

    def generate_permit_params(node = self::FIELDS)
      permitted = []
      expand_fields(node).each do |field|
        if field[:id]
          permitted <<
            if field[:type].is_a? Array
              {field[:id] => generate_permit_params(field[:type])}
            elsif field[:type] == 'checkbox'
              {field[:id] => field[:options].keys}
            else
              field[:id]
            end
        end
      end
      permitted
    end

    def generate_permit_params_wrapped(node = self::FIELDS)
      permitted = {}
      expand_fields(node).each do |field|
        if field[:id]
          permitted[field[:id]] = [:created_at, :updated_at,
            if field[:type].is_a? Array
              {:value => [:id, :created_at, :updated_at, generate_permit_params_wrapped(field[:type])]}
            elsif field[:type] == 'checkbox'
              {:value => field[:options].keys}
            else
              :value
            end
          ]
        end
      end
      permitted
    end
  end
end
