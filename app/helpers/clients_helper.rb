module ClientsHelper
  def ng_input(field, model)
    case field[:type]
    when 'dropdown'
      dropdownString = "<select name='#{field[:id]}' ng-model='#{model}'
                          #{field[:required] && 'required'}>
                        <option value=''>#{field[:placeholder]}</option>"
      field[:options].each do |option|
        dropdownString += "<option value='#{option}'>#{option}</option>"
      end
      dropdownString += "</select>"
      raw dropdownString
    when 'checkbox'
      checkboxString = ""
      field[:options].each do |option, key|
        checkboxString += "<div class='checkbox'><input name='#{field[:id]}' type='#{field[:type]}'
                                    ng-model='#{model}.#{option.camelize(:lower)}'
                                    id='#{field[:id]}'
                                    value='#{option}'
                                    #{field[:required] && 'required'}
                                  /><div class='checkbox-label'>#{key}</div></div>"
      end
      raw checkboxString
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
