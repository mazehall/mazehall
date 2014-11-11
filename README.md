# Mazehall

A mean stack framework with built-in multi node cluster features.

## Installation

    $ [sudo] npm install mazehall --save


## Usage

Create your own new application with an app.js like:

    var mazehall = require('mazehall');
    var config = require('config');
    var expressValidator = require('express-validator');
    var logger = require('morgan');
    
    mazehall.app.use(expressValidator());
    mazehall.app.use(logger(config.loggerOptions));
    
    mazehall.serve();
    
This starts the server dependently on the environment. Some defaults are set to bring up a core process.

## API

* `mazehall.app`
  * express instance

* `mazehall.serve()`
  * starts the server process with defaults or env settings

* `mazehall.server`
  * pointer to an instance of running server

## Predefined URIs

    app.get "/modules/aggregated.js"
    app.get "/modules/aggregated.css"
  * aggregated javascript and css resources from all enabled modules


### Environment variables

#### Port of server process
```
    PORT = 3000
```

#### Component Id
```
    MAZEHALL_COMPONENTS = 'core'
```

- string to identify the kind of server process like 'jsonApi' or 'admin' 
- 'core' processes load all modules 
- non core like 'admin' loads only the admin modules from the core

Non core modules are being live updated from core if a json file with the ```mazehall.socket``` key was found. The file must in be in the pattern ```<environmentString>.json``` and in the ```secrets``` directory.

    {
      "mazehall": {
        "socket": "bigSecret"
      }
    }

Don't check in this directory in your version control system. Set it to ignore. 

#### Core Socket
```
MAZEHALL_CORE_SOCKET = 'http://127.0.0.1:3000'
```

- Used only in non core process start


Example start log:

    Mazehall ui listening on port 3010
    [socket:ui] init socket
    [socket:ui] core server > http://127.0.0.1:3000
    [socket:ui] connected to core!
    [socket:ui] authentication with core...
    [socket:ui] authenticated on core
    [socket:ui] received modules (1) 
    [socket:ui] [1] foo @0.1.8
    [socket:ui] synchronize packages :
    [socket:ui] sync | local packages:  [ 'foo' ]
    [socket:ui] sync | remote packages:  [ 'foo' ]
    [socket:ui] sync | already installed package: foo



## Run Tests

``` bash
  $ npm test
```

#### License: MIT
#### Author: [Mazehall]
