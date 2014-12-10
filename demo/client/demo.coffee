# Demo
famous.polyfills;

{ Transform } = famous.core

# Create a client only collection
@Books = new Meteor.Collection null

Template.registerHelper 'checkedIf', (cond) ->
  if cond then 'checked' else ''

Template.registerHelper 'isOdd', (val) -> if val % 2 then 'odd' else 'even'

# Kudos go to http://javascriptweblog.wordpress.com/2011/08/08/fixing-the-javascript-typeof-operator/
toType = (obj) ->
  ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()

Template.registerHelper 'isDate', -> 'date' == toType @value

Session.setDefault 'maxByPage', 10
Session.setDefault 'currentPage', 1

# Define the schema
BookSchema = new SimpleSchema(
  title:
    type: String
    label: "Title"
    max: 200

  author:
    type: String
    label: "Author"

  copies:
    type: Number
    label: "Number of copies"
    min: 0

  lastCheckedOut:
    type: Date
    label: "Last date this book was checked out"
    optional: true

  summary:
    type: String
    label: "Brief summary"
    optional: true
    max: 1000
)

Session.setDefault 'fields', BookSchema.objectKeys()
Session.setDefault 'sortBy', {}

@defaultOptions =
  collection: Books
  schema: BookSchema
  maxPages: 3
  config:
    pagination: true

Template.reactiveFamous.helpers
  options: ->
    opts = _.clone defaultOptions
    page = Session.get 'currentPage'
    if page < 1 then page = 1
    opts.page = page
    opts.limit = Session.get 'maxByPage'
    opts.query = Session.get 'query'
    opts.fields = Session.get 'fields'
    opts.sort = Session.get 'sortBy'

    opts

Template.reactiveFamous.rendered = ->
  famous = FView.from @
  return

Template.reactiveBootstrap.helpers
  options: ->
    opts = _.clone defaultOptions
    page = Session.get 'currentPage'
    if page < 1 then page = 1
    opts.page = page
    opts.limit = Session.get 'maxByPage'
    opts.query = Session.get 'query'
    opts.fields = Session.get 'fields'
    opts.sort = Session.get 'sortBy'

    opts

Template.tableLayout_famous_column.rendered = ->
  fview = FView.from @
  console.log "column fview", fview, @
  {id} = @data
  fields = Session.get 'fields'
  index = fields.indexOf id
  fview.parent.modifier.setTransform Transform.translate(200*index, -50*index, 0),
    duration: 500, curve: 'easeOut'

Template.tableLayout_famous_row.rendered = ->
  fview = FView.from @
  console.log "row fview", fview, @
  {name} = @data
  fields = Session.get 'fields'
  index = fields.indexOf name
  fview.parent.modifier.setTransform Transform.translate(200*index, -50*index, 0),
    duration: 500, curve: 'easeOut'

Template.registerHelper 'translated', (modifier_id) ->
  mod = FView.byId modifier_id
  console.log "footer", @, mod
  mod.modifier.setTransform Transform.translate(0, 50+50*@data.rows.length),
    duration: 500, curve: 'linear'
  true

Template.tableLayout_bootstrap_columns.helpers
  'columns': ->
    currentFields = Session.get 'fields'
    allFields = BookSchema.objectKeys()
    allFields.map (field) ->
      {
        field: field
        isVisible: currentFields.indexOf(field) > -1
        title: BookSchema.label field
      }

Template.tableLayout_bootstrap_columns.events
  'click input': (evt, tmpl) ->
    fields = Session.get 'fields'
    if @isVisible
      fields.splice fields.indexOf(@field), 1
    else
      fields.push @field

    Session.set 'fields', fields
    return

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

Template.tableLayout_bootstrap_limit.helpers
  maxByPageOptions: [10, 25, 50, 100]
  selected: (val) ->
    if val is Session.get 'maxByPage' then 'selected' else ''

Template.tableLayout_bootstrap_limit.events
  'change select': (evt, tmpl) ->
    Session.set 'maxByPage', parseInt $(evt.currentTarget).val()
    return

Template.tableLayout_bootstrap_search.helpers

Template.tableLayout_bootstrap_search.events
  'keyup input': (evt, tmpl) ->
    Session.set 'query', $(evt.currentTarget).val()
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

Meteor.startup ->
  console.log "Welcome Meteor Hacker, you can try Books.insert({title: 'foo'});"
  console.log "Books property keys are:", BookSchema.objectKeys()
  return
