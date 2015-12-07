Template.tableLayout_bootstrap_useractions.events
  'click .fa-times': (evt, tmpl) ->
    fields = Session.get 'fields'
    unless fields instanceof Array
      console.error "Fields must be an array!", fields
      return
    Session.set 'fields', _.filter fields, (field) => field isnt @id
    return

  'click .fa-chevron-down': (evt, tmpl) ->
    sortBy = Session.get 'sortBy'
    sortBy[@id] = -1
    Session.set 'sortBy', sortBy
    return

  'click .fa-chevron-up': (evt, tmpl) ->
    sortBy = Session.get 'sortBy'
    sortBy[@id] = 1
    Session.set 'sortBy', sortBy
    return

Template.tableLayout_bootstrap_pagination.helpers
  disabledIfFirstPage: ->
    if @data.startIndex is 1 then 'disabled' else ''
  disabledIfLastPage: ->
    if @data.endIndex >= @data.count then 'disabled' else ''

Template.pagination_page.events
  'click': (evt, tmpl) ->
    evt.preventDefault()
    evt.stopImmediatePropagation()
    Session.set 'currentPage', @page
    return

Template.tableLayout_bootstrap_pagination.events
  'click .previous': (evt, tmpl) ->
    evt.preventDefault()
    evt.stopImmediatePropagation()
    Session.set 'currentPage', @data.page - 1
    return
  'click .next': (evt, tmpl) ->
    evt.preventDefault()
    evt.stopImmediatePropagation()
    Session.set 'currentPage', @data.page + 1
    return
