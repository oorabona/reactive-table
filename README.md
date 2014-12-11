# Meteor ReactiveTable

ReactiveTable, a Meteor package to provide you with reactively updated tabular data tables, pagination and search capabilities. All client side!

The demo shows a Bootstrap empty table. Open your browser console and when inserting data into the (client only) _Books_ collection, you should see the table auto updating !

## How it works
This package has been designed to _prepare_ data and make template bindings
easily. It handles pagination and search based queries.
Basically, options are checked and, if valid, 'layout' template will be rendered with this prepared data context.

## Usage

You simply need to call it from somewhere in your template:

```mustache
<template name="page">
  ...
  {{> ReactiveTable layout='myLayout' options=myOptions}}
  ...
</template>
```

Where:
* __layout__: template name to render
* __options__: instance options


### Options

ReactiveTable options need to be completed with data source.
All accepted options are:

* collection (_Meteor.Collection_) : Must specify an instance of Meteor.Collection. __[mandatory]__
* schema (_SimpleSchema_) : If you are using [SimpleSchema](https://github.com/aldeed/meteor-simple-schema), you can bind your instance __[optional]__
* fields (_Array of Strings_) : Visible fields. Only __[mandatory]__ if not using 'schema' above.
* fieldNames (_Object_) : Key is field, and value is the displayed title name. It will be used if set, otherwise if you provided a __schema__, it will get labels from SimpleSchema. And if not using SimpleSchema, it will default to __fields__.
* sort (_Object_) : Key/value pairs of columns to be sorted __[optional]__
* limit (_Integer_) : Limit output to this number of documents (by page). Must be > 0 __[default: 5]__
* page (_Integer_) : Go to this page (if using pagination). Must be > 0 __[default: 1]__
* maxPages (_Integer_) : When using pagination, set maximum displayable pages links. Must be >= 0 __[default: 5]__
* query (_String_ or _Object_) : Facet querying (see below) __[optional]__
* queryOpts (_String_) : When using query, will be used for RegExp options. E.g.: Use 'i' for insensitive match, 'g' for global, etc. __[default: 'i']__
* config (_Object_) : If you want to reuse your templates you might be interested in providing a configuration object, it is of no use for ReactiveTable and forwarded untouched to the template.

#### Example (Non-reactive):

From the _Books_ example of [Simple Schema](https://github.com/aldeed/meteor-simple-schema):
```coffee
Template.tableExample.helpers
  'myTableOptions':
    collection: Books
    schema: BookSchema
    fields: ['title', 'copies'] # Only part of BookSchema keys
    maxPages: 10
    limit: 50
    sort:
      copies: -1
      title: 1
```

#### Example (Reactive):
```coffee
Template.reactiveDemo.helpers
  options: ->
    opts =
      collection: Books
      fields: ['title', 'copies']
      schema: BookSchema
      maxPages: 3
      config:
        pagination: true

    page = Session.get 'currentPage'
    if page < 1 then page = 1
    opts.page = page
    opts.limit = Session.get 'maxByPage'
    opts.query = Session.get 'query'

    opts
```

### Layout

The most simple example:

```mustache
<template name="tableLayout_unstyled">
  <span>Got {{data.rows.length}} records</span>
  <table>
    {{#with header}}
    <thead>
      {{#each columns}}
      <td>
      {{title}}
      </td>
      {{/each}}
    </thead>
    {{/with}}
    {{#with data}}
    <tbody>
      {{#each rows}}
      <tr>
        {{#each values}}
        <td>
          {{name}} - {{value}}
        </td>
        {{/each}}
      </tr>
      {{/each}}
    </tbody>
    {{/with}}
  </table>
</template>
```

Layout template has its own data context it can parse to its liking.
You may or may not use all of these data:

```javascript
context = {
  // This is left untouched by ReactiveTable and is only needed if your
  // template may need setup (useful when reusing templates)
  config: {
    pagination: true
  },
  // If you want to use table headers, this will probably be helperful!
  header: {
    columns: [
      {
        id: 'col_title',
        title: 'Classy Title'
      },
      {
        id: 'author',
        title: 'Author'
      },
      {
        id: 'summary',
        title: 'Brief summary'
      }
    ]
  },
  data: {
    // Total number of records (filtered)
    count: 12,
    // First 'row id' of current page (starts at 1)
    startIndex: 11,
    // Last 'row id' to display endIndex - startIndex + 1 = rows.length
    endIndex: 12,
    // Page number (always > 0)
    page: 2,
    // Even if you do not use pagination, you will have an array of page(s)
    // that will give active status and page number. E.g. if on page 2:
    pages: [
      {
        active: false,
        page: 1
      },
      {
        active: true,
        page: 2
      }
    ],
    // Maximum pages needed to display all (filtered) documents
    totalPages: 2,
    // At the moment it is an array of rows containing an array of values
    rows: [
      {
        _id: "iA3x9gRnfigyMyDua",
        rowIndex: 1,
        values: [
          {
            name: 'col_title',
            value: 'Classic Title 1'
          },
          {
            name: 'author',
            value: undefined
          },
          {
            name: 'summary',
            value: 'Summary 1'
          }
        ]
      },
      {
        _id: "ZPp4wn2ZdPYhjXhf4",
        rowIndex: 2,
        values: [
          {
            name: 'col_title',
            value: 'Classic Title 2'
          },
          {
            name: 'author',
            value: 'Author'
          },
          {
            name: 'summary',
            value: undefined
          }
        ]
      }
    ]
  }
}
```

## Queries

Queries can be plain old _Object_ and used 'as is' or can be of type _String_ and have two syntaxes:

```coffee
# key:value
# This will search 'value' for key and 'bar' for foo
query = 'key:value foo:bar'
# A somewhat FTS example, this will search in all visible columns using RegExp
query = 'myvalue'
# The following will only consider 'key:value' pair and not 'myvalue' in the search
query = 'myvalue key:value'
```

## TODO

Tests, and more testing. Issues and PR are most welcomed !

## License

MIT
