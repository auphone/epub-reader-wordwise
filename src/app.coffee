Promise = require 'bluebird'
angular = require 'angular'
es = require './dist/components/database/es'
reader = require './dist/components/reader/reader'
$ = require 'jquery'
config = require './config.json'

angular
  .module 'app', [require('angular-sanitize')]
  .controller 'AppCtrl', class
    @$inject: ['$scope']
    constructor: (@scope) ->
      @connect()
        .then =>
          @readbook()
      angular.extend @scope, @
    connect: =>
      tasks = [
        es.connect()
        # @import()
      ]
      Promise.all tasks
    readbook: =>
      reader
        .read config.ebook.epub
        .then (book) =>
          @scope.book = book
          @scope.$apply()

          { flow }    = @scope.book
          width       = $('body').width()
          @scope.toc  = flow
          @scope.$apply()
        .catch (err) =>
          console.error err

# Directive
require './dist/directives/bookSection/bookSection'