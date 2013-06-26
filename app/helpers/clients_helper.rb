module ClientsHelper
  def ng_input(field, model)
    if field[:type] == 'dropdown'
      dropdownString = "<select name='#{:id}' ng-model='#{model}'
                          #{field[:required] && 'required'}>
                        <option value=''></option>"
      field[:options].each do |option|
        dropdownString += "<option value='#{option}'>#{option}</option>"
      end
      dropdownString += "</select>"
      raw dropdownString
    else
      raw "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:required] && 'required'}
              #{field[:validatePhone] && 'validate-phone'}
              ng-minlength='#{field[:minlength]}'
              ng-maxlength='#{field[:maxlength]}'
              ng-min='#{field[:min]}'
              ng-max='#{field[:max]}'
            />"
    end
  end
end
