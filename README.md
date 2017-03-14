# SQL_to_JSON_Loopback
This project will assist you in converting SQL Server entities into the JSON structure necessary for Loopback. I use this with the autoupdate() on for my server, which then generates the corresponding entities in my new datasource. You will need to configure your datasource separately, I provided an example using PostgresSQL below.

datasources.json sample:
```json
{
  "ds01": {
    "host": "127.0.0.1",
    "port": 5432,
    "database": "sampleDB",
    "password": "password",
    "name": "ds01",
    "user": "postgres",
    "connector": "postgresql",
    "debug": true
  }
}
```

server.js sample:
```javascript
'use strict';

var loopback = require('loopback');
var boot = require('loopback-boot');

var app = module.exports = loopback();


app.start = function() {
  // start the web server
  return app.listen(function() {
    app.emit('started');
    var baseUrl = app.get('url').replace(/\/$/, '');
    console.log('Web server listening at: %s', baseUrl);
    if (app.get('loopback-component-explorer')) {
      var explorerPath = app.get('loopback-component-explorer').mountPath;
      console.log('Browse your REST API at %s%s', baseUrl, explorerPath);
    }
  });
};

// Bootstrap the application, configure models, datasources and middleware.
// Sub-apps like REST API are mounted via boot scripts.
boot(app, __dirname, function(err) {
  if (err) throw err;

  // start the server if `$ node server.js`
  if (require.main === module)
    app.start();

  //Auto Update Models to DB Server, only those entities listed within this array are auto updated if required by passing
  //this data into the function below.
  var ds1 = app.dataSources.ds01;
  ds1.isActual(function(err, actual) {
    if (!actual) {
      ds1.autoupdate(function(err) {
        if (err) throw (err);
      });
    }
  });

});

```
