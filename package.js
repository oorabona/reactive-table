Package.describe({
  name: 'oorabona:reactive-table',
  summary: 'Reactive tables with many options',
  version: '1.0.6',
  git: 'https://github.com/oorabona/reactive-table.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');

  // Made with Coffee
  api.use('coffeescript@1.0.1', 'client');

  // Core
  api.use('templating', 'client');
  api.use('jquery', 'client');
  api.use('underscore', 'client');
  api.use('reactive-var@1.0.3', 'client');

  api.addFiles([
    'reactive-table.html',
    'reactive-table.coffee'
  ], 'client');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('oorabona:reactive-table');
  api.addFiles('reactive-table-tests.coffee');
});
