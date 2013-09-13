module ConsiliumFields
  def self.included(klass)
    klass.extend ClassMethods
    klass.const_set :FIELDS, YAML::load(File.open(Rails.root.join("config", "models", "#{klass.to_s.underscore}.yml")))
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

    def expand_fields_with_references(node = self::FIELDS)
      node.map do |field|
        if field[:type].is_a? Array
          f = field.dup
          f[:type] = expand_fields_with_references(f[:type])
          f
        elsif field[:type].is_a? Class
          f = field.dup
          f[:type] = field[:type]::FIELDS
          f
        else
          field
        end
      end
    end

    def verify_unique_ids(fields = self::FIELDS)
      ids = {}
      self.expand_fields(fields).each do |field|
        if field[:id]
          if field[:type].is_a?(Array) && field[:id].ends_with?('s')
            if !verify_unique_ids(field[:type])
              return false
            end
          end
          if ids[field[:id]]
            p field
            return false
          end
          ids[field[:id]] = true
        end
      end

      return true
    end

    def generate_permit_params(node = self::FIELDS)
      permitted = []
      expand_fields(node).each do |field|
        if field[:id]
          permitted <<
            if field[:type].is_a? Class
              {field[:id] => generate_permit_params(field[:type]::FIELDS)}
            elsif field[:type].is_a? Array
              {field[:id] => generate_permit_params(field[:type])}
            elsif field[:type] == 'checkbox'
              {field[:id] => field[:options].keys}
            elsif field[:type] == 'units'
              {field[:id] => [:qty, :unit]}
            else
              field[:id]
            end
        end
      end

      assocs = get_associations
      assocs.each do |assoc|
        permitted << assoc.to_s.singularize + "_id"
      end

      permitted << 'id'
      permitted << '_id'
      permitted
    end

    def generate_permit_params_wrapped(node = self::FIELDS)
      permitted = []
      expand_fields(node).each do |field|
        if field[:id]
          if field[:type].is_a?(Class) && !field[:type].syncable?
            # Drop out of wrapped mode if a referenced class is not syncable.
            permitted << {field[:id] => generate_permit_params(field[:type]::FIELDS)}
          else
            permitted << {field[:id] => [:created_at, :updated_at,
              if field[:type].is_a? Class
                {:value => [:id, :created_at, :updated_at, generate_permit_params_wrapped(field[:type]::FIELDS)]}
              elsif field[:type].is_a? Array
                {:value => [:id, :created_at, :updated_at, generate_permit_params_wrapped(field[:type])]}
              elsif field[:type] == 'checkbox'
                {:value => field[:options].keys}
              elsif field[:type] == 'units'
                {:value => [:qty, :unit]}
              else
                :value
              end
            ]}
          end
        end
      end

      assocs = get_associations
      assocs.each do |assoc|
        permitted << assoc.to_s.singularize + "_id"
      end

      permitted << 'id'
      permitted << '_id'
      permitted
    end

    def syncable
      @syncable = true
    end

    def syncable?
      @syncable
    end

    private
      def get_associations
        self.reflect_on_all_associations(:has_many).map(&:name)
      end

  end
end
