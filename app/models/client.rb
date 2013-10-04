if Rails.env == 'development'
  require_dependency 'consilium_fields'
  require_dependency 'consilium_field_references'
else
  require 'consilium_fields'
  require 'consilium_field_references'
end
require 'client_contact'
require 'file_attachment'
require 'andand'

class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paranoia
  include ConsiliumFields
  include ConsiliumFieldReferences
  include Impressionist::IsImpressionable

  is_impressionable

  belongs_to :brokerage

  syncable

  autosync_references :client_contacts

  has_many :client_changes, dependent: :delete
  has_many :client_contacts, dependent: :delete
  has_many :documents, dependent: :delete
  has_many :document_template_sections, dependent: :delete
  has_many :file_attachments, dependent: :delete

  field :editing_time, type: Integer, default: 0

  def sum_buildings(location)
    sum = 0
    if buildings = location['buildings'].andand['value']
      buildings.each do |b|
        if type = b['coverage_type'].andand['value']
          sum += b[type].andand['value'].to_i
        else
          sum += (b['replacement_cost'].andand['value'] || b['actual_cash_value'].andand['value']).to_i
        end
      end
    end
    sum
  end

  def sum_equipment(location)
    sum = 0
    if equipment = location['equipment_schedules'].andand['value']
      equipment.each do |equip|
        sum += equip['limit'].andand['value'].to_i
      end
    end
    sum
  end

  def create_file(name, raw_data, limit)
    # data URL format; data:<mime-type>;<charset etc>,<base64-encoded data>
    header, data = raw_data.split(',')
    mime_type = header.split(/[:;]/)[1]
    if data.nil? || (data = Base64.decode64(data)).empty?
      return nil
    end

    if !limit.nil? && data.length > limit
      return nil
    end

    file_data = {
      :name => name,
      :user => ProxyCurrentUser.current_user,
      :client => self,
      :mime_type => mime_type,
      :data => Moped::BSON::Binary.new(:generic, data),
    }

    f = FileAttachment.where(file_data).first
    if !f
      f = FileAttachment.new(file_data)
    end

    if f.save
      return f
    else
      return nil
    end
  end

  def finalize_scan(data, fields)
    changed = false

    if data.is_a?(Hash) && data['value']
      changed = finalize_scan(data['value'], fields)
      if changed
        data['updated_at'] = Time.now.to_i
      end
    elsif fields.is_a?(Hash) && fields.andand[:type] == 'file'
      # Create the file if it's a new upload.
      if data['raw_data']
        changed = true
        if f = create_file(data['name'], data['raw_data'], fields.andand[:limit])
          data['id'] = f.id.to_s
        end
        data.delete 'name'
        data.delete 'raw_data'
      end
    elsif data.is_a?(Hash)
      field_map = {}
      if fields.andand.is_a?(Array)
        fields.each do |field|
          field_map[field[:id]] = field
        end
      end
      data.each do |k, v|
        changed |= finalize_scan(v, field_map.andand[k])
      end
    elsif data.is_a?(Array)
      data.each { |d| changed |= finalize_scan(d, fields.andand[:type]) }
    end

    changed
  end

  # Post process some calculated data
  def finalize
    finalize_scan(self.attributes, Client.expand_fields_with_references)

    # Re-compute Building, Equipment, POED, COED sums in coverage schedules.
    if locations = self['locations'].andand['value']
      locations.each do |location|
        if covs = location['coverage_schedules'].andand['value']
          stock = 0
          covs.each do |cov|
            cat = cov['category'].andand['value']
            type = cov['type'].andand['value']
            if cat == 'Property' && type == 'Stock'
              stock = cov['limit'].andand['value'].to_i
            end
          end

          covs.each do |cov|
            cat = cov['category'].andand['value']
            type = cov['type'].andand['value']
            if cat == 'Property' && cov['limit']
              cov['limit']['value'] =
               (case type
                when 'Building'
                  sum_buildings(location)
                when 'Equipment'
                  sum_equipment(location)
                when /POED/
                  sum_buildings(location) + sum_equipment(location) + stock
                when /COED/
                  sum_equipment(location) + stock
                else
                  cov['limit']['value']
                end).to_s
            end
          end
        end
      end
    end

    self
  end

  def validate_value(field_name, field_desc, value)
    if value.nil? || value == ''
      if field_desc[:required]
        errors[field_name] << 'is required'
      end
    else
      case field_desc[:type]
      when 'text'
        value = value.to_s
        if field_desc[:maxlength] && value.length > field_desc[:maxlength]
          errors[field_name] << 'is too long'
        end
        if field_desc[:minlength] && value.length < field_desc[:minlength]
          errors[field_name] << 'is too short'
        end
      when 'integer'
        begin
          value = Integer(value)
        rescue
          errors[field_name] << 'must be an integer'
          return nil
        end
      when 'number'
        begin
          value = Float(value)
        rescue
          errors[field_name] << 'must be a number'
          return nil
        end
      when 'phone'
        value = value.to_s
        if !(/^([0-9][-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})(\s*(ext|x|extension)\.?\s*[0-9]+)?$/i.match(value))
          errors[field_name] << 'not valid phone number'
        end
      when 'email'
        value = value.to_s
        if !( /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.match(value))
          errors[field_name] << 'not valid email'
        end
      when 'currency'
        value = value.to_s
        if !(/^\d+(\.\d{0,2})?/i.match(value))
          errors[field_name] << 'not valid currency format'
        end
      when 'radio', 'dropdown'
        # Has to be one of the given values
        if !field_desc[:options].include?(value) && !field_desc[:options].include?('Other')
          errors[field_name] << 'is not one of the provided options'
        end
      when 'checkbox'
        # Each value has to be true/false
        if !value.nil?
          if value.is_a? Hash
            value.each do |key, val|
              value[key] = (val == true || val =~ /^(true|t|yes|on|y|1)$/i)
            end
          else
            errors[field_name] << 'must be a checkbox value'
          end
        end
      end
    end
    return value
  end

  def validate_field(obj, field, parent = nil)
    return if field[:id].nil?

    field_name = field[:id].underscore.humanize + (parent ? ' in ' + parent[:id].underscore.humanize.downcase : '')
    val = obj[field[:id]]
    if val.nil?
      if field[:required]
        errors[field_name] << 'is required'
      end
    elsif val['updated_at'].nil?
      errors[field_name] << 'must contain "updated_at"'
    elsif val['value'].nil?
      if field[:type].is_a?(Array)
        # Rails parses empty arrays as nil. Assume that's what happened
        val['value'] = []
      else
        errors[field_name] << 'must contain "value"'
      end
    elsif field[:type].is_a?(Array)
      if !val['value'].is_a?(Array)
        errors[field_name] << 'must be an array'
      else
        val['value'].each_with_index do |subval, i|
          field[:type].each do |subfield|
            validate_field(subval, subfield, field)
          end
        end
      end
    else
      value = validate_value(field_name, field, val['value'])
      val['value'] = value unless value.nil?
    end
  end

  def valid?(context = nil)
    errors.clear

    # Custom validation.
    Client.expand_fields.each do |field|
      validate_field(self, field)
    end

    errors.empty? && super(context)
  end
end
