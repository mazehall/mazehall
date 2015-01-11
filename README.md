# Mazehall

Mazehall is a flexible module loader system. Build on top of the Reactive Programming library 
[Kefir](https://pozadi.github.io/kefir/#).

An express interface is included. Stream all your routes into your app or configure a mask on startup.

## Installation

    $ [sudo] npm install mazehall --save


## Usage with express application

Create your own new application with an app.js like:

    var mazehall = require('mazehall');
    var express = require('express');
    
    var app, enableStream;
    app = express();
    enableStream = mazehall.initExpress(app);
    mazehall.moduleStream.log();
    app.listen(3000);
    

## API

* `mazehall.moduleStream`
  * handle a module stream bus
  * could be used for logging and custom interfaces

* `mazehall.loadStream([options])`
  * starts the module loading stream

* `mazehall.initExpress(app [, options])`
  * starts the module enable stream and processing for express interface


## Module interface

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
