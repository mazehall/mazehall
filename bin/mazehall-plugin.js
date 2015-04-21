#!/usr/bin/env node

var program = require("commander");
var mazecli = require("../lib/cli");

program.description("manage a mazehall plugin")
       .usage("[install|remove|update] [name]")
       .parse(process.argv);

/** exit, when arguments too short **/
if (program.args.length < 2) {
    program.help();
    process.exit();
}

try {
    switch(program.args[0]) {
        case "install":
            mazecli.installPlugin(program.args[1], true);
            break;
        case "remove":
            if (program.args.length === 4) {
                mazecli.databaseRemovePlugin(program.args[1], program.args[2], program.args[3]);
            } else {
                mazecli.removePlugin(program.args[1]);
            }
            break;
        case "update":
            mazecli.updatePlugin(program.args[1]);
            break;
        default:
            program.help();
    }
} catch(e) {
    if (e.code != "EEXIST") throw(e);
}