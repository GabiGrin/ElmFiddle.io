var COMPILED_DIR = '.comp';

// take a name as a string, return an elm object of the type
// the name given
var wrap_with_type = function(item){
  return {
    ctor: item
  };
};

// make the directory for compiled Elm code
var make_compile_dir = function(fs, dir){
  if (typeof dir === "undefined"){
    dir = COMPILED_DIR;
  }

  if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
  }
};

var setBody = function setBody(Task) {
  return function (request, encoding) {
    return Task.asyncFunction(function(callback){
      if (typeof encoding === "undefined" || encoding === null){
        encoding = "utf8";
      }

      var body = '';

      request.on('data', function (chunk) {
        body += chunk;
      });

      request.on('end', function () {
        request.body = body;
        callback(Task.succeed(request));
      });

      request.on('close', function () {
        request.body = body;
        callback(Task.succeed(request));
      });

      request.on('error', function (err) {
        callback(Task.fail(err));
      });
    });
  };
};

var setForm = function setForm(multiparty, fs, Task) {
  return function(request){
    return Task.asyncFunction(function(callback){
      var form = new multiparty.Form();

      form.parse(request, function(err, fields, files) {
        var vals = [];

        Object.keys(files || []).forEach(function(name, i){
          vals.push(files[name][0]);
        });

        var fieldVals = {};

        Object.keys(fields || []).forEach(function(name, i){
          fieldVals[name] = fields[name][0];
        });

        request.form = {
          fields: fieldVals,
          files: vals,
          ctor: "Form"
        };

        Object.keys(files || []).forEach(function(name, i){
          fs.writeFileSync(name, files[name]);
        });

        return callback(Task.succeed(request));
      });
    });
  };
};

var createServer = function createServer(fs, http, multiparty, Tuple2, Task) {
  return function (address) {
    make_compile_dir(fs, __dirname + "/" + COMPILED_DIR);

    var send = address._0;
    var server = http.createServer(function (request, response) {
      request.method = wrap_with_type(request.method);

      return Task.perform(send(Tuple2(request, response)));
    });
    return Task.asyncFunction(function (callback) {
      return callback(Task.succeed(server));
    });
  };
};

var listen = function listen(Task) {
  return function (port, echo, server) {
    return Task.asyncFunction(function (callback) {
      return server.listen(port, function () {
        console.log(echo);
        return callback(Task.succeed(server));
      });
    });
  };
};

var on = function on(Signal, Tuple0, Tuple2) {
  return function (eventName, x) {
    return x.on(eventName, function (request, response) {
      if (typeof(request) == 'undefined') {
        return Signal.input(eventName, Tuple0);
      }
      return Signal.input(eventName, Tuple2(request, response));
    });
  };
};

var parseQuery = function (Ok, Err, querystring){
  return function(query){
    var item = null;
    console.log(item, query);
    try {
      item = querystring.parse(query);
      console.log(item);
    } catch (err) {}

    if (typeof item !== "object"){
      return Err("Failed to parse item");
    }

    return Ok(item);
  };
};

var getQueryField = function(Just, Nothing) {
  return function(fieldName, queryDict){
    var item = queryDict[fieldName];

    if (typeof item === "undefined" || item === null){
      return Nothing;
    }

    return Just(item);
  };
};

var getFormField = function(Just, Nothing) {
  return function(fieldName, form) {
    console.log(form);
    var filed = getQueryField(Just, Nothing)(fieldName, form.fields);
    return filed;
  };
};

var getFormFiles = function(toList) {
  return function(form) {
    try {
      var convertedFiles = toList(form.files);
      return convertedFiles;
    } catch (err){
      return toList([]);
    }
  };
};

var fixedEncodeURIComponent = function() {
  return function(str) {
    return encodeURIComponent(str).replace(/[!'()*]/g, function(c) {
      return '%' + c.charCodeAt(0).toString(16);
    });
  };
};

var make = function make(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.Http = localRuntime.Native.Http || {};


  if (localRuntime.Native.Http.values) {
    return localRuntime.Native.Http.values;
  }

  var http = require('http');
  var fs = require('fs');

  var mime = require('mime');
  var querystring = require('querystring');

  var multiparty = require('multiparty');


  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);
  var Signal = Elm.Native.Signal.make(localRuntime);
  var Maybe = Elm.Maybe.make(localRuntime);
  var Result = Elm.Result.make(localRuntime);


  var Nothing = Maybe.Nothing;
  var Just = Maybe.Just;

  var Tuple0 = Utils['Tuple0'];
  var Tuple2 = Utils['Tuple2'];

  return {
    'createServer': createServer(fs, http, multiparty, Tuple2, Task),
    'listen': F3(listen(Task)),
    'on': F2(on(Signal, Tuple0, Tuple2)),
    'parseQuery': parseQuery(Result.Ok, Result.Err, querystring),
    'getQueryField': F2(getQueryField(Just, Nothing)),
    'getFormField': F2(getFormField(Just, Nothing)),
    'getFormFiles': getFormFiles(List.fromArray),
    'setForm': setForm(multiparty, fs, Task),
    'setBody': setBody(Task),
    'encodeUri': fixedEncodeURIComponent()

  };
};
Elm.Native.Http = {};
Elm.Native.Http.make = make;

if (typeof window === "undefined") {
  window = global;
}
