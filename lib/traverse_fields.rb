def traverse_fields(fields)
  fields.map! { |field|
    field[:id] = field[:id].underscore unless field[:id].nil? || !field[:id].is_a?(String)
    if field[:type].is_a?(Array)
      traverse_fields(field[:type])
    end
    field
  }
end

def write_fields(klass)
  fields = klass::FIELDS.dup();
  traverse_fields(fields)
  File.open(Rails.root.join("config", "models", "#{klass.to_s.downcase}.yml"), 'w') { |f| f.write(YAML.dump fields) }
end

def go
  write_fields Client
end
