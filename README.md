# Meteor Reactive Tables

This Meteor 1.0 Package helps you when you need to display reactively table
structured data. You can have a look at the [demo](http://reactive-table.meteor.com).

## Usage

Basically you insert reactive table within your template with:

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

> This package has been designed so that you are free to provide your own template rendering.

### Options

Reactive Table options need to be completed with data source.
All accepted options are:

* collection (_Meteor.Collection_) : Must specify an instance of Meteor.Collection. __[mandatory]__
* schema (_SimpleSchema_) : If you are using [SimpleSchema](http://github.com/aldeed/SimpleSchema), you can bind your instance __[optional]__
* fields (_Array of Strings_) : Visible fields. Only __[mandatory]__ if not using 'schema' above.
* fieldNames (_Array of Strings_) : Fields names to be display as header. It will be used if set, otherwise if __schema__ is used, it will get labels from SimpleSchema. And if not using SimpleSchema, it will default to __fields__.
* sort (_Object_) : Key/value pairs of columns to be sorted __[optional]__
* limit (_Integer_) : Limit output to this number of documents __[default: 5]__
* page (_Integer_) : Go to this page (if using pagination). Must be > 0 __[default: 1]__
* maxPages (_Integer_) : When using pagination, set maximum displayable pages links __[default: 1]__
* query (_String_ or _Object_) : Facet querying (see below) __[optional]__
* queryOpts (_String_) : When using query, will be used for RegExp options. E.g.: Use 'i' for insensitive match, 'g' for global, etc. __[default: 'i']__

#### Example (Non-reactive):
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
        {{#each this}}
        <td>
          {{value}}
        </td>
        {{/each}}
      </tr>
      {{/each}}
    </tbody>
    {{/with}}
  </table>
</template>
```

Layout template is fed with a responsive object with incoming data.
You are of course free to take care of all of them or only part of them in your
layout!
