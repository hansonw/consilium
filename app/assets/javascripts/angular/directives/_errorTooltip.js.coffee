App.directive 'errorTooltip', ->
  ($scope, elem, attrs) ->
    field = attrs.errorTooltip
    parent_form = elem.parents('form')
    dom_field = elem.parents('.pure-control-group').find("[name='#{field}']")
    form = $scope[parent_form.attr('name')]

    errors = {
      "minlength": "too short",
      "maxlength": "too long",
      "required": "required",
      "phone": "not a valid phone number",
      "email": "not a valid email",
      "min": "too small",
      "max": "too large",
      "pattern": "in the wrong format",
    }

    dom_field.on('focus', -> elem.html '')
    dom_field.on('blur', ->
      if form[field] && form[field].$error && !form[field].$pristine
        errs = []
        for key, val of form[field].$error
          errs.push("Field is #{errors[key]}") if val
        elem.html errs.join('<br />')
      else
        elem.html '')
