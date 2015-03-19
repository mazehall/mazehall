// including plugins
var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require("gulp-coffee");
var clean = require('gulp-clean');

var bases = {
  src: './src/**/*.coffee',
  dist: './lib/'
};
var coffeeOptions = {
  bare: true
}

gulp.task('clean', function() {
  return gulp.src(bases.dist, {read: false})
    .pipe(clean());
});

gulp.task('compile-coffee', ['clean'], function() {
  gulp.src(bases.src)
    .pipe(coffee(coffeeOptions).on('error', gutil.log))
    .pipe(gulp.dest(bases.dist));
});

gulp.task('watch-coffee', function () {
  gulp.watch(bases.src, ['compile-coffee']);
});

gulp.task('default', function() {
  gulp.start('compile-coffee');
});