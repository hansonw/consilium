module TableHelper
  def getPrimaryFieldsFromModel(model)
    primaryFields = []

    # Recurse down the model until we find a section that has primary fields.
    while model.is_a?(Array) && !model[0][:type].nil? && model[0][:type].is_a?(Array)
      model = model[0][:type]
    end

    model.each do |field|
      next if !field[:primary]
      primaryField = {
        :name => field[:name],
        :content => "{{ item.#{field[:id]}.value || item.#{field[:id]} }}"
      }
      primaryField[:class] = field[:type] if field[:type] != 'text'
      primaryFields.push primaryField
    end

    primaryFields
  end
end
