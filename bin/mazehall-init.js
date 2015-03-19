#!/usr/bin/env node

var program = require("commander");
var mazecli = require("../lib/cli");

program.description("creates an mazehall app")
       .usage("<appname> [options]")
       .option("-f, --force", "overwrite exists file")
       .parse(process.argv);

try {
    mazecli.createMazeApp(process.cwd(), program);
} catch(e) {
    if (e.code != "EEXIST") throw(e);
}