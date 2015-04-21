# Mazehall

Mazehall is a flexible module loader system. Build on top of the Reactive Programming library 
[Kefir](https://pozadi.github.io/kefir/#).

An express interface is included. Stream all your routes into your app or configure a mask on startup.

## Installation

    $ [sudo] npm install --save mazehall


## Usage

### Manually case

Create your own new application with an testable app.js like:

    var mazehall = require('mazehall');
    var express = require('express');
    
    var app, server;
    app = express();
    server = require('http').Server(app);
    
    mazehall.moduleStream.log('module loader');
    mazehall.initExpress(app);
    
    module.exports = server;
    
and a startup file server.js like:

    var server = require('./app.js');
    
    var port;
    port = process.env.PORT || 3000
    server.listen(port, function() {
      console.log('server listen on port: ' + port);
    });
    

### Command line case

Let's do it mazehall cli.  

    $ [sudo] npm install mazehall -g
    
A global installation is an optional step. You could also call the cli interface in the node_modules/.bin directory.
 
    mkdir myapp
    cd myapp
    mazehall init
    
At this point you have an mazehall application with express integration. Now you need at least an application module. 

    mazehall module gui
    
That's all.

    npm start
    
    server listen on port: 3000
    module loader <value> { module: 'gui', components: [ 'ui', '' ] }
    


## API

### Module loader interface

* `mazehall.moduleStream`
  * handle a module stream bus
  * could be used for logging and custom interfaces

* `mazehall.loadStream([options])`
  * starts the module loading stream

* `mazehall.initExpress(app [, options])`
  * starts the module enable stream and processing for express interface


### Module interface

By default Mazehall is looking for modules in the ```app_module/*``` directories.
Place a package.json file in the modules and add at least the ```mazehall: true``` key.
More complex scenarios uses the ```components: ['restapi','admin']``` array to handle the enabled
modules. See also the [mazehall-seed example app](https://github.com/mazehall/mazehall-seed).

An example package.json
```
    {
      "name": "moduleGui",
      "version": "0.1.0",
      "description": "User Interface",
      "main": "index.js",
      "mazehall": true,
      "components": ["ui"],
      "author": "Jens Klose",
      "license": "MIT"
    }
```


### Plugin interface

/* tbd */

### Environment variables

#### Component Id
```
    MAZEHALL_COMPONENTS = 'api,cloud'
```

- string to identify the kind of server process like 'jsonApi' or 'admin' 
- 'core' processes load all modules 
- non core like 'admin' loads only the admin modules from the core

## Run Tests

``` bash
  $ npm test
```

#### License: MIT
#### Author: [Mazehall]
