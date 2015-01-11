# Mazehall

A express application module loader system. Stream your routes into your app
and configure a mask on startup.

## Installation

    $ [sudo] npm install mazehall --save


## Usage

Create your own new application with an app.js like:

    var mazehall = require('mazehall');
    
    var app, enableStream;
    app = express();
    enableStream = mazehall.init(app);
    //enableStream.log();
    module.exports = app;
    
This starts the server dependently on the environment. Some defaults are set to bring up a core process.

## API

* `mazehall.init(app)`
  * starts the module enable stream and processing


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
