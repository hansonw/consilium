module FormHelper
  def model_name(field_name, parent_field, syncable)
    return "#{parent_field}.#{field_name}" + (syncable ? '.value' : '')
  end

  def form_field(field, parent_field, syncable = true)
    parent_field = 'client' if parent_field.nil?

    model = model_name(field[:id], parent_field, syncable)
    if field[:if]
      if field[:if].start_with? '$'
        showIf = field[:if][1..-1]
      else
        negate = false
        showIf = field[:if]
        if field[:if].start_with? '!'
          showIf = field[:if][1..-1]
          negate = true
        end

        parts = showIf.split('.')
        parts[0] = model_name(parts[0], parent_field, syncable)
        if parts.length > 1
          showIf = parts.join('.') # checkbox
        else
          showIf = parts[0] + ' == "yes"' # radio
        end

        if negate
          showIf = "!(#{showIf})"
        end
      end
    end

    return raw\
      "<div class='pure-control-group'
            #{field[:if] && "data-ng-show='#{showIf}'"}>
         <label for='#{field[:id]}'
                #{field[:required] && "class='required'"}
                #{parent_field == 'client' && "data-ng-class='changedFields.#{field[:id]} && \"changed\"'"}>
           #{field[:name]}
         </label>
         #{ng_input(field, model)}
       </div>"
  end

  def pattern(str)
    return "ng-pattern='/#{str}/' pattern='#{str}'"
  end

  def ng_input(field, model)
    r = ''
    case field[:type]
    when 'dropdown'
      dropdownString = "<div class='dropdown-field'>
                          <select class='dropdown-list' name='#{field[:id]}'
                            data-dropdown-other='#{model}'
                            #{field[:required] && 'required'}
                            #{field[:intelligentStates] && 'intelligentStates'}
                            #{field[:readonly] && 'readonly'}>
                          <option value=''>#{field[:placeholder]}</option>"
      if field[:id] == 'province'
        field[:options].each do |country|
          country[1].each do |state|
            dropdownString += "<option value='#{state}' id='#{country[0]}'>#{state}</option>"
          end
        end
      else
        field[:options].each do |option|
          dropdownString += "<option value='#{option}'>#{option}</option>"
        end
      end
      dropdownString += "</select>"
      if field[:otherPlaceholder] != ''
        dropdownString +=  "<div class='other-field'>
                              <input name='#{field[:id]}'
                                type='hidden'
                                data-dropdown-other='#{model}' placeholder='#{field[:otherPlaceholder]}'
                                #{field[:optionRequired] && 'required'}
                                #{field[:readonly] && 'readonly'}
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
                                value='#{key}'
                                ng-checked=\"#{checked}\"
                                #{field[:required] && 'required'}
                                #{field[:readonly] && 'readonly'}
                            />
                            <label for='#{field[:id]}' class='checkbox-label'>#{option}</label>
                          </div>"
      end
      r = "<div class='checkbox-container'>" + checkboxString + "</div>"
    when 'textbox'
      # Textarea placeholders cause weird bugs in IE10. Disabled for now.
      r = "<textarea name='#{field[:id]}' ng-model='#{model}'
                #{false && field[:placeholder] && "placeholder='#{field[:placeholder]}'"}
                #{field[:prefill] && field[:prefill][:auto] && "prefill='#{field[:prefill][:auto]}'"}
                #{field[:prefill] && field[:prefill][:calc] && "prefill-calc='#{field[:prefill][:calc]}'"}
                #{field[:required] && 'required'}
                #{field[:readonly] && 'readonly'}
                rows='#{field[:boxRows]}'
            /></textarea>"
    when 'currency', 'phone'
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:prefill] && field[:prefill][:auto] && "prefill='#{field[:prefill][:auto]}'"}
              #{field[:prefill] && field[:prefill][:calc] && "prefill-calc='#{field[:prefill][:calc]}'"}
              #{field[:required] && 'required'}
              #{field[:readonly] && 'readonly'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:type] == 'currency' && pattern('\d+(\.\d{0,2})?') + "title='No dollar sign and no comma(s) - cents are optional'"}
              #{field[:type] == 'phone' && pattern('^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$') + "title='Must have format: 1234567890, 123-456-7890, or 123.456.7890'"}
            />"
    else
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:prefill] && field[:prefill][:auto] && "prefill='#{field[:prefill][:auto]}'"}
              #{field[:prefill] && field[:prefill][:calc] && "prefill-calc='#{field[:prefill][:calc]}'"}
              #{field[:required] && 'required'}
              #{field[:readonly] && 'readonly'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:pattern] && pattern(field[:pattern])}
              #{field[:errorMessage] && "title='#{field[:errorMessage]}'"}
              #{field[:type] == 'date' && "placeholder-polyfill"}
            />"
    end

    return raw r.gsub("\n", "").squeeze(' ')
  end
end
