@Books = new Meteor.Collection null

Session.setDefault 'maxByPage', 10
Session.setDefault 'currentPage', 1
Session.setDefault 'tableLayout', 'bootstrap'

# Define the schema
@BookSchema = new SimpleSchema(
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

Template.registerHelper 'isOdd', (val) -> if val % 2 then 'odd' else 'even'

# Kudos go to http://javascriptweblog.wordpress.com/2011/08/08/fixing-the-javascript-typeof-operator/
toType = (obj) ->
  ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase()

Template.registerHelper 'isDate', -> 'date' == toType @value

Template.registerHelper 'checkedIf', (cond) ->
  if cond then 'checked' else ''

Template.navbar.events
  'click button': (evt, tmpl) ->
     dialog = document.getElementById 'add_dialog'
     dialog.showModal()

Template.add.events
  'close': (evt, tmpl) ->
    {returnValue} = evt.currentTarget
    console.log 'close event', returnValue
    if returnValue is 'save'
      {insertDoc} = AutoForm.getFormValues 'insert'
      if insertDoc
        Books.insert insertDoc
      else
        throw new Error 'Bad document !'
    return

@defaultOptions =
  collection: Books
  schema: BookSchema
  maxPages: 3
  config:
    pagination: true

Template.layout.helpers
  selectedDemo: ->
    opts = _.clone defaultOptions
    page = Session.get 'currentPage'
    if page < 1 then page = 1
    opts.page = page
    opts.limit = Session.get 'maxByPage'
    opts.query = Session.get 'query'
    opts.fields = Session.get 'fields'
    opts.sort = Session.get 'sortBy'

    {
      layout: "tableLayout_#{Session.get 'tableLayout'}"
      options: opts
    }

Template.setColumns.helpers
  'columns': ->
    currentFields = Session.get 'fields'
    allFields = BookSchema.objectKeys()
    allFields.map (field) ->
      {
        field: field
        isVisible: currentFields.indexOf(field) > -1
        title: BookSchema.label field
      }

Template.setColumns.events
  'click input': (evt, tmpl) ->
    fields = Session.get 'fields'
    if @isVisible
      fields.splice fields.indexOf(@field), 1
    else
      fields.push @field

    Session.set 'fields', fields
    return

Template.setLimit.helpers
  maxByPageOptions: [10, 25, 50, 100]
  selected: (val) ->
    if val is Session.get 'maxByPage' then 'selected' else ''

Template.setLimit.events
  'change select': (evt, tmpl) ->
    Session.set 'maxByPage', parseInt $(evt.currentTarget).val()
    return

Template.setLayout.helpers
  availLayouts: ['bootstrap', 'unstyled']
  selected: (val) ->
    if val is Session.get 'tableLayout' then 'selected' else ''

Template.setLayout.events
  'change select': (evt, tmpl) ->
    Session.set 'tableLayout', $(evt.currentTarget).val()
    return

Template.setSearch.helpers

Template.setSearch.events
  'keyup input': (evt, tmpl) ->
    Session.set 'query', $(evt.currentTarget).val()
    return

Meteor.startup ->
  console.log "Welcome Meteor Hacker, you can try Books.insert({title: 'foo'});"
  console.log "Books property keys are:", BookSchema.objectKeys()
  return
