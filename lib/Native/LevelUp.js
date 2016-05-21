var levelup = require('levelup');

var openOrCreate = function (str) {
  return levelup(str);
};

var put = function(Task, Tuple0) {
  return function (db, key, value) {
    return Task.asyncFunction(function(callback) {
      try {
        db.put(key, value, function(err) {
          if (err) {
            callback(Task.fail(err));
          }
          console.log('put in db', key, value, err);

          callback(Task.succeed(Tuple0));
        });
      } catch (e) {
        console.error(e);
        Task.fail(e);
      }
    });
  };
};

var get = function(Task, Tuple0) {
  return function (db, key) {
    return Task.asyncFunction(function(callback) {
      try {
        db.get(key, function(err, data) {
          console.log('get in db 11', key, data, typeof data, err);
          if (err) {
            callback(Task.fail(err.toString()));
          } else if (typeof data === 'undefined') {
            console.log('und');
            callback(Task.fail(new Error('Not found')));
          } else {
            callback(Task.succeed(data));
          }
        });
      } catch (e) {
        console.error(e);
        Task.fail(e);
      }
    });
  };
};

var getAll = function(Task) {
  return function (db) {
    return Task.asyncFunction(function(callback) {
      try {
        var all = [];
        db.createReadStream()
        .on('data', function (data) {
          all.push({key: data.key, value: JSON.parse(data.value)});
        })
        .on('error', function (err) {
          callback(Task.fail(err));
          console.log('Oh my!', err);
        })
        .on('end', function () {
          console.log(all);
          callback(Task.succeed(JSON.stringify(all)));
        });
      } catch (e) {
        console.error(e);
        Task.fail(e);
      }
    });
  };
}


var make = function make(elm) {
  elm.Native = elm.Native || {};
  elm.Native.LevelUp = elm.Native.LevelUp || {};

  if (elm.Native.LevelUp.values) return elm.Native.LevelUp.values;

  var Task = Elm.Native.Task.make(elm);

  var Utils = Elm.Native.Utils.make(elm);


  function log(string)
  {
    return Task.asyncFunction(function(callback) {
      console.log(string);
      return callback(Task.succeed(Utils.Tuple0));
    });
  }

  return elm.Native.LevelUp.values = {
    openOrCreate: openOrCreate,
    put: F3(put(Task, Utils.Tuple0)),
    get: F2(get(Task)),
    getAll: getAll(Task),
    log: log,
    now: function () {
      return Task.asyncFunction(function (cb) {
        return cb(Task.succeed(Date.now()));
      });
    }
  };
};

Elm.Native.LevelUp = {};
Elm.Native.LevelUp.make = make;
