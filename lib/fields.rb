def expand_fields(node = FIELDS)
  fields = node.map do |field|
    if field[:type].is_a?(Array) && !field[:id].ends_with?('s')
      field[:type]
    else
      field
    end
  end
  return fields.flatten
end

def generate_permit_params(node)
  permitted = {}
  expand_fields(node).each do |field|
    if field[:id]
      permitted[field[:id]] = [:updated_at,
        if field[:type].is_a? Array
          {:value => generate_permit_params(field[:type])}
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
