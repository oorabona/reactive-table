Template.registerHelper '$eq', (what, to) ->
  what is to
  
Template.tableLayout_bootstrap_useractions.helpers
  sortState: ->
    sortBy = Session.get 'sortBy'
    sort = sortBy[@id]
    switch sort
      when 1 then 'asc'
      when -1 then 'desc'
      else 0

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

  'click .fa-ban': (evt, tmpl) ->
    sortBy = Session.get 'sortBy'
    delete sortBy[@id]
    Session.set 'sortBy', sortBy
    return

  'click .fa-chevron-up': (evt, tmpl) ->
    sortBy = Session.get 'sortBy'
    sortBy[@id] = 1
    Session.set 'sortBy', sortBy
    return

Template.tableLayout_bootstrap_pagination.helpers
  disabledIfFirstPage: ->
    if @data.page is 1 then 'disabled' else ''
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
