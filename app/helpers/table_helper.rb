module TableHelper
  def getPrimaryFieldsFromModel(model)
    primaryFields = []

    # Recurse down the model until we find a section that has primary fields.
    begin
      isArray = model.is_a?(Array) && !model[0][:type].nil? && model[0][:type].is_a?(Array)
      isClass = model.is_a?(Class)

      model = model[0][:type] if isArray
      model = model::FIELDS if isClass
    end until !isArray && !isClass

    model.each do |field|
      next if !field[:primary]
      primaryField = {
        :name => field[:name],
        :id => field[:id],
        :content => "{{ item.#{field[:id]}.value || item.#{field[:id]} }}"
      }
      primaryField[:class] = field[:type] if field[:type] != 'text'
      primaryField[:content] = "{{ (item.#{field[:id]}.value || item.#{field[:id]}) * 1000 | date: 'yyyy-MM-dd' }}" if field[:type] == 'date'
      primaryFields.push primaryField
    end

    primaryFields
  end
end