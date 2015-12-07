# ReactiveTable demo with Famo.us !!

This is a demo (needs a bit more work) of using ```ReactiveTable``` with [Famo.us](http://famous.org).
It starts with no data, so you need to add some, e.g.:

```javascript
Books.insert({
  title: 'foo',
  author: 'baz',
  copies: 3,
  lastCheckedOut: new Date(),
  summary: 'Summary...'
});
```

__Note:__
_lastCheckedOut_ will be displayed using your current locale settings.

There are also several _Session_ variables to play with !
