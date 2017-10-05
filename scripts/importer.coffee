# Lib
fs = require 'fs'
Promise = require 'bluebird'
readline = require 'line-by-line'

# Config
config = require '../config.json'

# Elastic
EsClient = require('elasticsearch').Client
  hosts: config.es.host
  log: null

class Importer

  constructor: (@dbFiles, @dbName) ->

  run: =>
      Promise.each @dbFiles, (dbFile) =>
        return @insertEntry dbFile
      .then ->
        console.log 'DONE!'
      .catch (err) ->
        console.error err

  insertEntry: (dbFile) =>
    return new Promise (rs, rj) =>
      entries = []
      lastRecord = null
      lineReader = new readline dbFile
      lineReader
        .on 'line', (line) =>
          record = @splitEntry line
          if @duplicateCheck entries, record, lastRecord
            return
          entries.push record
          lastRecord = record
          if entries.length >= 250
            lineReader.pause()
            @insert entries
              .finally ->
                entries = []
                lineReader.resume()
        .on 'end', =>
          return rs() if entries is 0
          @insert(entries).finally -> rs()

  insert: (entries) =>
    return new Promise (rs, rj) =>
      arr = []
      for entry in entries
        arr.push
          index:
            _index: @dbName
            _type: @dbName
        arr.push entry
      return EsClient
        .bulk { body: arr }
        .then ->
          console.log "Inserted #{entries.length} record."
          rs()
        .catch (err) ->
          console.error err
          rj err

  splitEntry: (entry) ->
    return {}

  duplicateCheck: ->
    return false


module.exports = Importer