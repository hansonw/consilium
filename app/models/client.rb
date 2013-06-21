class Client
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  FIELDS = [
    {
      :name => 'Name',
      :id => 'name',
      :placeholder => 'Firstname Lastname',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Address',
      :id => 'address',
      :placeholder => 'Address (apt., suite, bldg.)',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'City and Province',
      :id => 'cityAndProvince',
      :placeholder => 'City, Province',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Phone',
      :id => 'phone',
      :placeholder => 'Area code - phone #, ext #',
      :type => 'text',
      :required => true,
    },
    {
      :name => 'Client Contacts',
      :id => 'clientContacts',
      :type => [
        {
          :name => 'Name',
          :id => 'name',
          :placeholder => 'Firstname Lastname',
          :type => 'text',
          :required => true,
        },
        {
          :name => 'Title',
          :id => 'title',
          :placeholder => 'Mr./Mrs./Dr. (etc)',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Business Ops',
      :id => 'businessOps',
      :type => [
        {
          :name => 'Name',
          :id => 'name',
          :placeholder => 'Firstname Lastname',
          :type => 'text',
          :required => true,
        },
      ],
    },
    {
      :name => 'Claims Info',
      :id => 'claimsInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Liability Info',
      :id => 'liabilityInfos',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Misc. Notes',
      :id => 'miscNotes',
      :type => [
        {

        },
      ],
    },
    {
      :name => 'Coverage Schedule',
      :id => 'coverageSchedules',
      :type => [
        {

        },
      ],
    },
    {
      :name => 'Properties',
      :id => 'properties',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Umbrella/Machinery',
      :id => 'umbrellaMachinery',
      :type => [
        {
        },
      ],
    },
    {
      :name => 'Photos',
      :id => 'photos',
      :type => [
      ],
    },
  ]

  def validate_scalar(field_name, field_desc, value)
    if value.nil?
      if field_desc[:required]
        errors[field_name] << 'is required'
      end
    elsif field_desc[:type] == 'text'
      value = value.to_s
      if field_desc[:maxlength] && value.length > field_desc[:maxlength]
        errors[field_name] << 'is too long'
      end
      if field_desc[:minlength] && value.length < field_desc[:minlength]
        errors[field_name] << 'is too short'
      end
    elsif field_desc[:type] == 'int'
      begin
        value = Integer(value)
      rescue
        errors[field_name] << 'must be an integer'
        return nil
      end
    end

    return value
  end

  def valid?(context = nil)
    errors.clear
    # Custom validation.
    FIELDS.each do |field|
      val = self[field[:id]]

      if val.nil?
        if field[:required]
          errors[field[:id]] << 'is required'
        end
      elsif val['updated_at'].nil?
        errors[field[:id]] << 'must contain "updated_at"'
      elsif val['value'].nil?
        errors[field[:id]] << 'must contain "value"'
      elsif field[:type].is_a?(Array)
        if !val['value'].is_a?(Array)
          errors[field[:id]] << 'must be an array'
        else
          val['value'].each_with_index do |subval, i|
            field[:type].each do |subfield|
              subval[subfield[:id]] = validate_scalar(subfield[:id], subfield, subval[subfield[:id]])
            end
          end
        end
      else
        val['value'] = validate_scalar(field[:id], field, val['value'])
      end
    end

    errors.empty? && super(context)
  end
end
