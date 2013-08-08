module TableHelper
  def getPrimaryFieldsFromModel(model)
    primaryFields = []

    model.each do |field|
      next if !field[:primary]
      primaryField = {
        :name => field[:name],
        :content => "{{ item.#{field[:id]} }}"
      }
      primaryField[:class] = field[:type] if field[:type] != 'text'
      primaryFields.push primaryField
    end

    primaryFields
  end
end
