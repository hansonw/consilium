module ClientsHelper
  def ng_input(field, model)
    raw "<input name='#{field[:id]}' type='#{field[:type]}'
            ng-model='#{model}' placeholder='#{field[:placeholder]}'
            #{field[:required] && 'required'}
            ng-minlength='#{field[:minlength]}'
            ng-maxlength='#{field[:maxlength]}'
            ng-min='#{field[:min]}'
            ng-max='#{field[:max]}'
          />"
  end
end
