var compileString = require('node-elm-compile-string');

var compile = function(Task) {
  return function (code) {
    return Task.asyncFunction(function (callback) {
			compileString(code)
				.then(code => callback(Task.succeed(code)), err => callback(Task.fail(err.toString())));
    });
  }
};


var make = function make(elm) {
    elm.Native = elm.Native || {};
    elm.Native.ElmCompiler = elm.Native.ElmCompiler || {};

    if (elm.Native.ElmCompiler.values) return elm.Native.ElmCompiler.values;

    var Task = Elm.Native.Task.make(elm);

    var Utils = Elm.Native.Utils.make(elm);

    return elm.Native.ElmCompiler.values = {
        'compile': compile(Task)
    };
};

Elm.Native.ElmCompiler = {};
Elm.Native.ElmCompiler.make = make;
