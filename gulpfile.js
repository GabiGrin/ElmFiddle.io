'use strict';
var gulp = require('gulp');
var elm = require('gulp-elm');
var insert = require('gulp-insert');
var nodemon = require('gulp-nodemon');
var gutil = require('gulp-util');
var chalk = require('chalk');
var livereload = require('gulp-livereload');
var open = require('open');
var del = require('del');
var shell = require('gulp-shell');
var notifier = require('node-notifier');


gulp.task('clean', function () {
  return del([
    'dist/',
    // here we use a globbing pattern to match everything inside the `mobile` folder
    'frontend/dist',
    // we don't want to clean this file though so we negate the pattern
    'elm-stuff'
  ]);
});

gulp.task('test', ['elm-init'], () => {
  return gulp.src('tests/*.elm')
  .pipe(elm().on('error', gutil.log))
  .pipe(gulp.dest('tmp/'))
  .pipe(shell(
    [ 'echo start elm-test build'
    , 'sh ./elm-stuff/packages/laszlopandy/elm-console/1.1.1/elm-io.sh tmp/Main.js tmp/test.js'
    , 'node tmp/test.js' ]
  ))
});

gulp.task('watch-server', ['compile-backend'], function () {
  nodemon({
    script: 'dist/server.js',
    ext: 'js',
    watch: [
      'dist/server.js'
    ],
  })
  .on('restart', function () {
    gutil.log(chalk.yellow('Server restarted!'));
  });
});

gulp.task('elm-init', elm.init);

gulp.task('compile-backend', ['elm-init'], function () {
  return gulp.src('backend/server.elm')
  .pipe(elm().on('error', function (err) {
    gutil.log(err.message);
    notifier.notify({title: 'Error compiling backend', message: err.message});
  }))
  .pipe(insert.append('Elm.worker(Elm.Main);\n'))
  .pipe(gulp.dest('dist/'));
});

gulp.task('develop-backend', ['compile-backend', 'watch-server'], function () {
});

gulp.task('compile-frontend', ['elm-init'], function () {
  livereload();
  return gulp.src('frontend/Main.elm')
  .pipe(elm().on('error', function (err) {
    gutil.log(err);
    notifier.notify('Error compiling frontend');
  }))
  .pipe(gulp.dest('frontend/dist'))
  .pipe(livereload());
});

gulp.task('reload-index', function () {
  gulp.src('frontend/index.html')
  .pipe(livereload());
});

gulp.task('build', ['compile-frontend', 'compile-backend']);

gulp.task('default', ['compile-backend', 'compile-frontend', 'watch-server'], function () {
  livereload.listen();
  // gulp.watch('**/*.elm', ['test']);
  gulp.watch('backend/*.elm', ['compile-backend']);
  gulp.watch('frontend/*.elm', ['compile-frontend']);
	gulp.watch('common/*.elm', ['compile-frontend', 'compile-backend']);
  gulp.watch('frontend/index.html', ['reload-index']);

  open('http://localhost:8080/');
});
