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

Meteor.startup ->
  console.log "Welcome Meteor Hacker, you can try Books.insert({title: 'foo'});"
  console.log "Books property keys are:", BookSchema.objectKeys()
  return
