var cuid = require('cuid');


var _cuid = function(Task){
    return function(){
      console.log('returning cuid!', cuid());
        return Task.asyncFunction(function (callback) {
          console.log('returning cuid!', cuid());
            return callback(Task.succeed(cuid()));
        });
    };
};

var make = function make(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Cuid = elm.Native.Cuid || {};

  if (elm.Native.Cuid.values) return elm.Native.Cuid.values;
console.log('maken');
  var Task = Elm.Native.Task.make(elm);
console.log('maketh');
  return elm.Native.Cuid.values = {
    cuid: _cuid(Task)
  };
};

Elm.Native.Cuid = {};
Elm.Native.Cuid.make = make;
