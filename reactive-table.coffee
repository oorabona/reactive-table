# Reactive Table

Template.ReactiveTable.helpers
  data: ->
    @_table = new ReactiveTable @options
    @_table.getData()

class ReactiveTable
  constructor: (@_options = {}) ->
    unless @_options.collection
      throw new Error "ReactiveTable needs a collection!"

    @_options.page ?= 1
    check @_options.page, Number
    unless @_options.page > 0
      throw new Error "ReactiveTable page option must be > 0"

    # Make sure maxPages and limit are Numbers
    @_options.maxPages ?= 5
    check @_options.maxPages, Number
    unless @_options.maxPages >= 0
      throw new Error "ReactiveTable maxPages option must be >= 0"
    @_options.limit ?= 5
    check @_options.limit, Number
    unless @_options.limit > 0
      throw new Error "ReactiveTable limit option must be > 0"

    # Set default find options fields and sorts
    @_fields = _id: 1
    @_sort = {}

    # If this package is installed, new option appear!
    if Package["aldeed:simple-schema"]
      if @_options.schema instanceof SimpleSchema
        @_useSchema = true

    # If we are using SimpleSchema, fields must be the return value of
    # SimpleSchema.objectKeys().
    if @_useSchema
      @_options.fields ?= @_options.schema.objectKeys()
    else
      unless @_options.fields?.length
        throw new Error "Reactive Table: when not using SimpleSchema, fields options must be set!"

    # Default sort attribute
    for field in @_options.fields
      @_fields[field] = 1
      @_sort[field] = @_options.sort?[field]

    # If we have a query, it might be either an object litteral or a string
    query = {}
    if @_options.query
      if typeof @_options.query == 'string'
        # Check if we have something like 'foo:bar grab:me'
        # http://stackoverflow.com/questions/13586371/regex-extract-key-value-no-delimiter
        match = @_options.query.match /\b(\w+):\s*([^:]*\S)\b\s*(?=\w+:|$)/g

        # If true, parse it and get a plain old Javascript Object
        if match
          # For each match try to make it look like a '{"key":"value"}' so that
          # it can be parsed successfully by JSON.parse
          match.forEach (el) ->
            kv_pair = "{\"#{el}\"}".split(':').join '":"'
            # Remove double quotes if number is detected
            # http://stackoverflow.com/questions/5834901/jquery-automatic-type-conversion-during-parse-json
            kv_pair = kv_pair.replace(/"(-?\d)/g, "$1").replace(/(\d)"/g, "$1")
            _.extend query, JSON.parse kv_pair
        else
          # By default search is case insensitive
          @_options.queryOpts ?= 'i'
          # Looks like a string then, search any visible field
          regex = new RegExp @_options.query, @_options.queryOpts
          # query needs to be an array for MongoDB $or
          query = []
          for key in @_options.fields
            obj = {}
            obj[key] = regex
            query.push obj
      else if @_options.query instanceof Object
        query = @_options.query
      else
        throw new Error "Reactive Table query can be either an object litteral or a string"

    @_query = query

    @_options.showHeader ?= true
    @_options.showBodyIfNoData ?= true

    return

ReactiveTable::getData = ->
  {collection, fields, showHeader, showBodyIfNoData} = @_options

  result = config: @_options.config

  if showHeader
    labels = []
    # Get human readable column name
    # order is: 'user defined', 'SimpleSchema' else field name
    for field in fields
      fieldName = @_options.fieldNames?[field]
      if fieldName
        labels.push id: field, title: fieldName
      else if @_useSchema
        labels.push
          id: field
          title: @_options.schema.label field ? 'No label'
      else
        labels.push id: field, title: field

    result.header =
      columns: labels

  query = {}
  if @_query instanceof Array
    query["$or"] = @_query
  else
    query = @_query

  found = @_options.collection.find query
  data = count: found.count()

  # Math magic under this line!
  data.totalPages = Math.ceil(data.count / @_options.limit)
  if data.totalPages is 0 then data.totalPages = 1

  # If page is 'ouf of bounds', i.e. above totalPages
  if @_options.page > data.totalPages
    @_options.page = 1

  # Query again with these options
  opts =
    sort: @_sort
    fields: @_fields
    skip: @_options.limit * (@_options.page - 1)
    limit: @_options.limit

  found = @_options.collection.find query, opts

  # For reading convenience :)
  data.startIndex = opts.skip + 1
  data.endIndex = if data.startIndex + opts.limit > data.count
    data.count
  else opts.skip + opts.limit
  data.page = @_options.page

  data.pages = ((opt_maxPages) ->
    {totalPages} = data

    pageBase = opt_maxPages * Math.floor data.page / (opt_maxPages+1)

    maxPages = totalPages - pageBase
    if maxPages > opt_maxPages
      maxPages = opt_maxPages
    {
      page: idx+1+pageBase
      active: idx+1+pageBase is data.page
    } for idx in [0..maxPages-1]
  )(@_options.maxPages)

  data.rows = found.map (row, index) ->
    {
      _id: row._id
      rowIndex: index + 1    # startIndex + rowIndex <= endIndex
      values: (name: field, value: row[field] ? `undefined` for field in fields)
    }

  if data.rows.length > 0 or showBodyIfNoData
    result.data = data

  result
