module FormHelper
  def model_name(field_name, parent_field, options)
    return if field_name.nil?
    # Pull out any expressions contained within the field name and add them back
    # after we append |.value|, if we're going to.
    expr = /(  *)(!)?(=)?(\=|<|>).*$/.match field_name
    field_name = field_name.sub(expr.to_s, '')
    model = "#{parent_field}.#{field_name}" + (options[:syncable] ? '.value' : '')
    model = model + expr.to_s
    return model
  end

  def form_field(field, parent_field, options = {})
    if !options.has_key?(:syncable)
      options[:syncable] = true
    end

    model = model_name(field[:id], parent_field, options)
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
        parts[0] = model_name(parts[0], parent_field, options)
        if parts.length > 1
          showIf = parts.join('.') # checkbox
        else
          # Append |== "yes"| if there is no expression contained within the conditional.
          showIf = parts[0] + (if !(showIf.match /\=|<|>/) then ' == "yes"' else '' end) # radio
        end

        if negate
          showIf = "!(#{showIf})"
        end
      end
    end

    if field[:type] == 'heading'
      return raw\
        "<div class='pure-control-group' #{field[:if] && "data-show-emit='#{h showIf}'"}>
          <label></label>
          <div class='heading'>#{h field[:text]}</div>
        </div>"
    elsif field[:type] == 'separator'
      return raw\
        "<div class='pure-control-group' #{field[:if] && "data-show-emit='#{h showIf}'"}>
          <label></label>
          <hr class='soften'></hr>
        </div>"
    end

    changed = options[:changed] || "changedFields.#{field[:id]}"

    return raw\
      "<div class='pure-control-group'
            #{field[:if] && "data-show-emit='#{h showIf}'"}>
         <label for='#{field[:id]}'
                #{field[:required] && "class='required'"}
                data-ng-class='{changed: #{changed}}'
                title='#{field[:type] == 'checkbox' ? 'Highlighted fields were changed' : "{{ #{changed} }}"}'>
           #{field[:name]}
           <div class='error-tooltip' error-tooltip='#{field[:id]}' />
         </label>
         #{ng_input(field, model, options)}
       </div>"
  end

  def pattern(str)
    return "ng-pattern='/#{str}/' pattern='#{str}'"
  end

  def ng_input(field, model, options)
    r = ''

    case field[:type]
    when 'dropdown'
      dropdownString = "<div class='dropdown-field'>
                          <select class='dropdown-list #{field[:id]}' name='#{field[:id]}'
                            data-dropdown-other='#{model}'
                            #{field[:intelligent] && "model='#{h options[:model_parent]}'"}
                            #{field[:required] && 'required'}
                            #{field[:intelligent] && 'intelligent'}
                            #{field[:readonly] && 'readonly'}>
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
        changed = options[:changed] || "changedFields.#{field[:id]}"
        checkboxString += "<div class='checkbox-field'
                                ng-click=\"#{click_action}\"
                                ng-class=\"{changed: #{changed}.#{key}}\">
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
                #{field[:prefill] && field[:prefill][:type] == 'static' && "prefill='#{field[:prefill][:text]}'"}
                #{field[:prefill] && field[:prefill][:type] == 'calc' && "prefill-calc prefill-expr='#{field[:prefill][:expr]}'"}
                #{field[:prefill] && field[:prefill][:type] == 'watch' && "prefill-watch='#{field[:prefill][:watch]}' prefill-expr='#{field[:prefill][:expr]}'"}
                #{field[:required] && 'required'}
                #{field[:readonly] && 'readonly'}
                rows='#{field[:boxRows]}'
            /></textarea>"
    when 'currency', 'phone'
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:prefill] && field[:prefill][:type] == 'static' && "prefill='#{field[:prefill][:text]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'calc' && "prefill-calc prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'watch' && "prefill-watch='#{field[:prefill][:watch]}' prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:required] && 'required'}
              #{field[:readonly] && 'readonly'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:type] == 'currency' && pattern('\d+(\.\d{1,2})?') + "title='No dollar sign and no comma(s) - cents are optional' restrict='[$,]'"}
              #{field[:type] == 'phone' && pattern('^([0-9][-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})(\s*(ext|x|extension)\.?\s*[0-9]+)?$')\
                + "title='Use the format 1-123-456-7890 ext. 1234 (dashes, country code, ext. optional)'"}
            />"
    when 'date'
      r = "<input type='hidden' ng-model='#{model}' />
           <input name='#{field[:id]}' type='datepicker'
              model='#{model}' placeholder='#{field[:placeholder] || "Select a date"}'
              #{field[:prefill] && field[:prefill][:type] == 'static' && "prefill='#{field[:prefill][:text]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'calc' && "prefill-calc prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'watch' && "prefill-watch='#{field[:prefill][:watch]}' prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:required] && "required"}
              #{field[:readonly] && "readonly"}
              #{field[:pattern] && pattern(field[:pattern])}
              #{field[:errorMessage] && "title='#{field[:errorMessage]}'"}
              #{field[:type] == 'date' && 'datepicker'}
            />
           <a class='ui-datepicker-clear' href=''><i class='icon-remove-sign'></i></a>"
    else
      r = "<input name='#{field[:id]}' type='#{field[:type]}'
              ng-model='#{model}' placeholder='#{field[:placeholder]}'
              #{field[:prefill] && field[:prefill][:type] == 'static' && "prefill='#{field[:prefill][:text]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'calc' && "prefill-calc prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'watch' && "prefill-watch='#{field[:prefill][:watch]}' prefill-expr='#{field[:prefill][:expr]}'"}
              #{field[:prefill] && field[:prefill][:type] == 'sequence' && "prefill-sequence='#{h options[:model_parent]}'"}
              #{field[:required] && 'required'}
              #{field[:readonly] && 'readonly'}
              #{field[:minlength] && "ng-minlength='#{field[:minlength]}'"}
              #{field[:maxlength] && "ng-maxlength='#{field[:maxlength]}'"}
              #{field[:min] && "ng-min='#{field[:min]}'"}
              #{field[:max] && "ng-max='#{field[:max]}'"}
              #{field[:pattern] && pattern(field[:pattern])}
              #{field[:intelligent] && "model='#{h options[:model_parent]}'"}
              #{field[:intelligent] && 'intelligent'}
              #{field[:errorMessage] && "title='#{field[:errorMessage]}'"}
            />"
    end

    return raw r.gsub("\n", "").squeeze(' ')
  end

  def fieldAsCollection(field)
    if field[:type].is_a?(Class)
      field = field.dup()
      # Link the field to the class that it's referring to's fields.
      field[:type] = field[:type]::FIELDS
      return field
    elsif field[:type].is_a?(Array)
      return field
    else
      return nil
    end
  end

  def actionHandleDefault(action, id, rowHref)
    newAction = action

    if action == :delete
      newAction = {
        :icon => 'icon-trash',
        :class => 'pure-button-error',
        :click => "deleteFromField('#{id}', null, $index)",
      }
    elsif action == :show
      newAction = {
        :icon => 'icon-angle-right',
        :href => rowHref,
        :class => 'pure-icon',
      }
    elsif action == :edit
      newAction = {
        :icon => 'icon-edit',
        :click => "editInField('#{id}', null, $index)"
      }
    end

    newAction
  end
end
