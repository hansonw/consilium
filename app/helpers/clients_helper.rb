module ClientsHelper
  def ng_input(field, model)
    case field[:type]
    when 'dropdown'
      dropdownString = "<div class='dropdown-field'>
                          <select class='dropdown-list' name='#{field[:id]}' ng-model='#{model}'
                            #{field[:required] && 'required'}>
                          <option value=''>#{field[:placeholder]}</option>"
      field[:options].each do |option|
        dropdownString += "<option value='#{option}'>#{option}</option>"
      end
      dropdownString += "</select>"
      if field[:otherPlaceholder] != ''
        dropdownString += "<input class='other-field' name='#{field[:id]}' 
                              type=\"{{(#{model} == 'Other') ? 'text' : 'hidden'}}\"
                              ng-model='#{model}' placeholder='#{field[:otherPlaceholder]}'
                              #{field[:optionRequired] && 'required'}
                              ng-minlength='#{field[:minlength]}'
                              ng-maxlength='#{field[:maxlength]}'
                              ng-min='#{field[:min]}'
                              ng-max='#{field[:max]}'
                          />"
      end
      dropdownString += "</div>"
      raw dropdownString
    when 'checkbox'
      checkboxString = ""
      field[:options].each do |key, option|
        checkboxString += "<div class='checkbox-field'>
                            <input name='#{field[:id]}'
                                type='#{field[:type]}'
                                ng-click=\"#{model} = (#{model} == '#{key}') ? '' : '#{key}'\"
                                id='#{key}'
                                value='#{key}'
                                #{field[:required] && 'required'}
                            />
                            <div class='checkbox-label'>#{option}</div>
                          </div>"
      end
      raw checkboxString
    when 'radio'
      checkboxString = ""
      field[:options].each do |key, option|
        checkboxString += "<div class='checkbox-field'>
                            <input name='#{field[:id]}'
                                type='#{field[:type]}'
                                ng-click=\"#{model} = (#{model} == '#{key}') ? '' : '#{key}'\"
                                id='#{key}'
                                value='#{key}'
                                ng-checked=\"#{model} == '#{key}'\"
                                #{field[:required] && 'required'}
                            />
                            <div class='checkbox-label'>#{option}</div>
                          </div>"
      end
      raw checkboxString
    when 'textbox'
      raw "<textarea name='#{field[:id]}' ng-model='#{model}'
                placeholder='#{field[:placeholder]}'
                #{field[:required] && 'required'}
                rows = '#{field[:boxRows]}'
            /></textarea>"
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
