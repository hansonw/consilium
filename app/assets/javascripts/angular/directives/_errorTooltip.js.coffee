App.directive 'errorTooltip', ['$timeout', ($timeout) ->
  ($scope, elem, attrs) ->
    init = ->
      field = attrs.errorTooltip
      parentForm = elem.parents('form')
      domField = elem.parents('.pure-control-group').find(":input[name='#{field}']")
      form = $scope[parentForm.attr('name')]

      if modal = parentForm.attr('node')
        $('div#modal-' + modal).on 'modal-toggle', -> elem.html ''

      errors = {
        "minlength": "is too short",
        "maxlength": "is too long",
        "required": "is required",
        "phone": "is not a valid phone number",
        "email": "is not a valid email",
        "min": "is too small",
        "max": "is too large",
        "pattern": "is in the wrong format",
        "unique": "is not unique",
        "password_match": "does not match the entered password"
      }

      if domField.is('select')
        eventType = 'change'
      else
        domField.on('focus', -> elem.html '')
        eventType = 'blur'
      domField.on eventType, (event) ->
        if domField.is('select') && domField.val() == '' && domField.attr('required')
          elem.html 'Field is required'
        else if domField.attr('intelligent')? && domField.attr('required')
          elem.html 'Field is required' if domField.val() == ''
        else if form[field] && form[field].$error && !form[field].$pristine
          errs = []
          for key, val of form[field].$error
            errs.push("Field #{errors[key]}") if val
          elem.html errs.join('<br />')
        else
          elem.html ''

    # Wait until the field's controller loads.
    $timeout init, 0
]
