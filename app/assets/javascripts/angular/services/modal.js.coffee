App.factory 'Modal', [->
  toggleModal: (modalName) ->
    $('body').toggleClass('modal-active')
    $(".modal[id~='modal-#{modalName}']").toggleClass('active')
]
