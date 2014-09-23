// including plugins
var gulp = require('gulp');
var coffee = require("gulp-coffee");
var watch = require("gulp-watch");
var clean = require('gulp-clean');

var bases = {
  src: './src/**/*.coffee',
  dist: './lib/'
};

gulp.task('clean', function() {
  return gulp.src(bases.dist)
    .pipe(clean());
});

gulp.task('compile-coffee', ['clean'], function() {
  gulp.src(bases.src)
    .pipe(coffee())
    .pipe(gulp.dest(bases.dist));
});

gulp.task('watch-coffee', function () {
  gulp.watch(bases.src, ['compile-coffee']);
});

gulp.task('default', function() {
  gulp.start('compile-coffee');
});