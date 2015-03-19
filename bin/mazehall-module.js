#!/usr/bin/env node

var program = require("commander");
var mazecli = require("../lib/cli");

program.description("create a new mazehall module")
       .usage("[name] [options]")
       .option("-f, --force", "overwrite exists files")
       .parse(process.argv);

/** exit, when no arguments given **/
if (program.args.length === 0) {
    program.help();
    process.exit();
}

try {
    mazecli.createAppModule(undefined, program.args[0], program);
} catch(e) {
    if (e.code != "EEXIST") throw(e);
}