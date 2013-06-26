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
      field[:options].each do |key, option|
        checkboxString += "<div class='checkbox-field'><input name='#{field[:id]}' type='#{field[:type]}'
                              ng-click=\"#{model} = (#{model}=='#{key}')?'':'#{key}'\"
                              id='#{key}'
                              value='#{key}'
                              ng-checked=\"#{model} == '#{key}'\"
                              #{field[:required] && 'required'}
                            /><div class='checkbox-label'>#{option}</div></div>"
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
