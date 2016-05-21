var packages = require('./github-packages');
var del = require('del');
var shell = require('shelljs');
var path = require('path');
var pathToLib = path.join(__dirname, './lib/from-github');
var chalk = require('chalk');
var githubPrefix = 'http://www.github.com/';


function log(msg) {
  var now = 'GHP - [' + new Date().toLocaleTimeString() + ']';
  console.log(chalk.gray(now), msg);
}
del.sync(pathToLib);
log('cleaning lib folder ' + chalk.yellow(pathToLib));

shell.exec('mkdir ' + pathToLib);


Object.keys(packages)
  .forEach(function (packagePath) {
    var fullPath = githubPrefix + packagePath;
    var dirName = packagePath.split('/')[1];
    log('cloning ' + chalk.green(packagePath) + ' from ' + chalk.green(fullPath));
    shell.exec('git clone ' + fullPath, {cwd: pathToLib});
    log('removing .git files in ' + chalk.green(dirName));
    console.log('.git - ', path.join(pathToLib, dirName, '/.git'));
    del.sync(path.join(pathToLib, dirName, '/.git'));
  });
