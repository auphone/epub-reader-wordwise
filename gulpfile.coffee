gulp    = require 'gulp'
plugins = require('gulp-load-plugins')()

gulp.task 'compile:coffee', ->
  gulp
    .src './src/**/*.coffee'
    .pipe plugins.coffee()
    .pipe gulp.dest('./dist/')
    .pipe plugins.livereload()

gulp.task 'watch', ->
  plugins.livereload.listen
    port: 35734
  gulp.watch './src/**/*.coffee', ['compile:coffee']

gulp.task 'default', ['compile:coffee']

gulp.task 'serve', ['default', 'watch']