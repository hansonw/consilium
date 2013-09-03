App.directive 'errorTooltip', ['$timeout', ($timeout) ->
  ($scope, elem, attrs) ->
    init = ->
      field = attrs.errorTooltip
      parentForm = elem.parents('form')
      domField = elem.parents('.pure-control-group').find(":input[name='#{field}']")
      form = $scope[parentForm.attr('name')]

      errors = {
        "minlength": "too short",
        "maxlength": "too long",
        "required": "required",
        "phone": "not a valid phone number",
        "email": "not a valid email",
        "min": "too small",
        "max": "too large",
        "pattern": "in the wrong format",
        "unique": "not unique",
      }

      if domField.is('select')
        eventType = 'change'
      else
        domField.on('focus', -> elem.html '')
        eventType = 'blur'
      domField.on(eventType, (event) ->
        if domField.is('select') && domField.val() == '' && domField.attr('required')
          elem.html 'Field is required'
        else if form[field] && form[field].$error && !form[field].$pristine
          errs = []
          for key, val of form[field].$error
            errs.push("Field is #{errors[key]}") if val
          elem.html errs.join('<br />')
        else
          elem.html '')

    # Wait until the field's controller loads.
    $timeout init, 0
]
