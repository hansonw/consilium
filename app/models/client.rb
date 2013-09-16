if Rails.env == 'development'
  require_dependency 'consilium_fields'
else
  require 'consilium_fields'
end
require 'consilium_field_references'
require 'client_contact'

class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paranoia
  include ConsiliumFields
  include ConsiliumFieldReferences

  belongs_to :brokerage

  syncable

  autosync_references :client_contacts

  has_many :client_changes, dependent: :delete
  has_many :client_contacts, dependent: :delete
  has_many :documents, dependent: :delete
  has_many :document_template_sections, dependent: :delete

  field :editing_time, type: Integer, default: 0

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
      when 'number'
        begin
          value = Integer(value)
        rescue
          errors[field_name] << 'must be an integer'
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
