var levelup = require('levelup');
var cp = require('ncp').ncp;
var guid = process.argv[2];
var db = levelup('./ldb-storage');

// 
// db.get(guid, function (err, data) {
//   console.log('error', err);
//   console.log('data', data);
// });


db.createReadStream()
  .on('data', function (data) {
    console.log(data.key, '=', data.value)
  })
  .on('error', function (err) {
    console.log('Oh my!', err)
  })
  .on('close', function () {
    console.log('Stream closed')
  })
  .on('end', function () {
    console.log('Stream closed')
  })
