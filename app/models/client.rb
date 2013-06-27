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
      :name => 'Company',
      :id => 'company',
      :placeholder => 'Name of Company',
      :type => 'text',
      :required => false,
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
        {
          :name => 'Position',
          :id => 'position',
          :type => 'dropdown',
          :placeholder => '',
          :options => [
            'Accountant',
            'CEO',
            'Insured',
            'Manager',
            'Owner',
            'President',
            'Principal',
            'Secretary',
            'Vice President',
            'Other',
          ],
          :otherPlaceholder => 'Specify',
        },
        {
          :name => 'Phone',
          :id => 'phone',
          :placeholder => 'Area code - phone #, ext #',
          :type => 'text',
          :validatePhone => true,
        },
        {
          :name => 'Email',
          :id => 'email',
          :placeholder => 'john@consilium.ca',
          :type => 'email',
        },
        {
          :name => 'Other',
          :id => 'other',
          :placeholder => 'Main, Direct, Toll, Fax, Pager, Cell, Home',
          :type => 'text',
        },
      ],
    },
    {
      :name => 'Business Ops',
      :id => 'businessOps',
      :type => [
        {
          :name => 'Industry Code',
          :id => 'name',
          :placeholder => '000000',
          :type => 'text',
          :required => true,
        },
        {
          :name => 'Description of operations:',
          :id => 'descriptionOperations',
          :placeholder => 'Description of operations',
          :type => 'textbox',
          :boxRows => 5,
        },
      ],
    },
    {
      :name => 'Claims Info',
      :id => 'claimsInfos',
      :type => [
      ],
    },
    {
      :name => 'Prev. Policy Info',
      :id => 'prevPolicyInfos',
      :type => [
      ],
    },
    {
      :name => 'Liability Info',
      :id => 'liabilityInfos',
      :type => [
      ],
    },
    {
      :name => 'Policy Info',
      :id => 'policyInfos',
      :type => [
      ],
    },
    {
      :name => 'Payment Info',
      :id => 'paymentInfos',
      :type => [
      ],
    },
    {
      :name => 'Location Info',
      :id => 'locationInfos',
      :type => [
        {
          :name => 'Inspection',
          :id => 'inspection',
          :type => 'checkbox',
          :options => {
            'notInspected' => 'This risk was not inspected',
          },
        },
        {
          :name => 'This risk is:',
          :id => 'riskSeverity',
          :type => 'checkbox',
          :options => {
            'excellent' => 'Excellent',
            'good' => 'Good',
            'veryGood' => 'Very Good',
            'average' => 'Average',
            'fair' => 'Fair',
            'poor' => 'Poor',
          },
        },
      ],
    },
    {
      :name => 'Risk Info',
      :id => 'riskInfos',
      :type => [
      ],
    },
    {
      :name => 'Misc. Notes',
      :id => 'miscNotes',
      :type => [
      ],
    },
    {
      :name => 'Coverage',
      :id => 'coverages',
      :type => [
      ],
    },
    {
      :name => 'Properties',
      :id => 'properties',
      :type => [
      ],
    },
    {
      :name => 'Umbrella/Machinery',
      :id => 'umbrellaMachinery',
      :type => [
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
        if !(/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/i.match(value))
          errors[field_name] << 'not valid phone number'
        end
      when 'email'
        value = value.to_s
        if !( /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.match(value))
          errors[field_name] << 'not valid email'
        end
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
        if field[:type].is_a?(Array)
          # Rails parses empty arrays as nil. Assume that's what happened
          val['value'] = []
        else
          errors[field[:id]] << 'must contain "value"'
        end
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
