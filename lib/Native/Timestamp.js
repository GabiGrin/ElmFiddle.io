
var getTimestamp = function(Task) {
  return function () {
    console.log('gettting');
    return Task.asyncFunction(function (callback) {
			callback(Date.now());
    });
  }
};


var make = function make(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Timestamp = elm.Native.Timestamp || {};

    if (elm.Native.Timestamp.values) return elm.Native.Timestamp.values;

    var Task = Elm.Native.Task.make(elm);

    return elm.Native.Timestamp.values = {
        'getTimestamp': getTimestamp(Task)
    };
};

Elm.Native.Timestamp = {};
Elm.Native.Timestamp.make = make;
