module ClientsHelper
  def model_name(field_name, parent_field)
    return parent_field.nil? ? "client.#{field_name}.value" : "#{parent_field[:id]}.#{field_name}"
  end

  def client_field(field, parent_field: nil, show_changed: false)
    model = model_name(field[:id], parent_field)
    if field[:if]
      negate = false
      showIf = field[:if]
      if field[:if].start_with? '!'
        showIf = field[:if][1..-1]
        negate = true
      end

      parts = showIf.split('.')
      parts[0] = model_name(parts[0], parent_field)
      if parts.length > 1
        showIf = parts.join('.') # checkbox
      else
        showIf = parts[0] + ' == "yes"' # radio
      end

      if negate
        showIf = "!(#{showIf})"
      end
    end

    return raw\
      "<div class='pure-control-group' #{field[:if] && "data-ng-show='#{showIf}'"}>
         <label for='#{field[:id]}' #{field[:required] && "class='required'"} #{show_changed && "data-ng-class='changedFields.#{field[:id]} && \"changed\"'"}>
           #{field[:name]}
         </label>
         #{ng_input(field, model)}
       </div>"
  end

  def ng_input(field, model)
    r = ''
    case field[:type]
    when 'dropdown'
      dropdownString = "<div class='dropdown-field'>
                          <select class='dropdown-list' name='#{field[:id]}'
                            data-dropdown-other='#{model}'
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
                                type='hidden'
                                data-dropdown-other='#{model}' placeholder='#{field[:otherPlaceholder]}'
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
    when 'currency', 'phone'
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:required] && 'required'}
              #{field[:disabled] && 'disabled'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:type] == 'currency' && 'pattern=\'\d+(\.\d{0,2})?\'' + "title='No dollar sign and no comma(s) - cents are optional'"}
              #{field[:type] == 'phone' && 'pattern=\'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$\'' + "title='Must have format: 1234567890, 123-456-7890, or 123.456.7890'"}
            />"
    when 'photo'
      r="<div style='' name='#{field[:id]}' ng-model='#{model}' 
                #{field[:required] && 'required'}
                #{field[:disabled] && 'disabled'}
                id='cameraOptions'>
                <div class='well' >
                <a id='CapturePhoto' data-ng-click='sccapturePhoto()' class='pure-button pure-button-primary' style=''><i class='icon-camera'></i></a>
                <a id='settingsCamera' data-ng-click='findPhoto()' class='pure-button pure-button-primary' style=''><i class='icon-picture'></i></a>
                <input type='file' capture='camera' accept='image/*' class='takePictureField' />
                <img style='display:none;' id='largeImage' src='' />
                <img class='yourimage'/>
                </div>
              </div>"
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
              #{field[:type] == 'date' && "placeholder-polyfill"}
            />"
    end

    return raw r.gsub("\n", "").squeeze(' ')
  end
end
