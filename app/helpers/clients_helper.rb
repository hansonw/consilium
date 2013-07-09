module ClientsHelper
  def ng_input(field, model)
    r = ''
    case field[:type]
    when 'dropdown'
      dropdownString = "<div class='dropdown-field'>
                          <select class='dropdown-list' name='#{field[:id]}' ng-model='#{model}'
                            ng-class='#{model} == \"Other\" && \"other-dropdown\"'
                            #{field[:required] && 'required'}
                            #{field[:disabled] && 'disabled'}>
                          <option value=''>#{field[:placeholder]}</option>"
      field[:options].each do |option|
        dropdownString += "<option value='#{option}'>#{option}</option>"
      end
      dropdownString += "</select>"
      if field[:otherPlaceholder] != ''
        dropdownString +=  "<div class='other-field'>
                              <input name='#{field[:id]}'
                                type=\"{{(#{model} == 'Other') ? 'text' : 'hidden'}}\"
                                ng-model='#{model}' placeholder='#{field[:otherPlaceholder]}'
                                #{field[:optionRequired] && 'required'}
                                #{field[:disabled] && 'disabled'}
                              />
                            </div>"
      end
      dropdownString += "</div>"
      r = "<div class='dropdown-container'>" + dropdownString + "</div>"
    when 'checkbox', 'radio'
      checkboxString = ""
      field[:options].each do |key, option|
        click_action = "toggleRadio('#{model}', '#{key}')"
        checked = "#{model} == '#{key}'"
        if field[:type] == 'checkbox'
          click_action = "toggleCheckbox('#{model}.#{key}')"
          checked = "#{model}.#{key}"
        end
        checkboxString += "<div class='checkbox-field'
                            ng-click=\"#{click_action}\">
                            <input name='#{field[:id]}'
                                type='#{field[:type]}'
                                id='#{key}'
                                value='#{key}'
                                ng-checked=\"#{checked}\"
                                #{field[:required] && 'required'}
                                #{field[:disabled] && 'disabled'}
                            />
                            <span class='checkbox-label'>#{option}</span>
                          </div>"
      end
      r = "<div class='checkbox-container'>" + checkboxString + "</div>"
    when 'textbox'
      r = "<textarea name='#{field[:id]}' ng-model='#{model}'
                placeholder='#{field[:placeholder]}'
                #{field[:required] && 'required'}
                #{field[:disabled] && 'disabled'}
                rows='#{field[:boxRows]}'
            /></textarea>"
    else
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:required] && 'required'}
              #{field[:disabled] && 'disabled'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:pattern] && "pattern='#{field[:pattern]}'"}
              #{field[:errorMessage] && "title='#{field[:errorMessage]}'"}
            />"
    end

    return raw r.gsub("\n", "").squeeze(' ')
  end
end
