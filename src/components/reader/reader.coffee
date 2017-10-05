Promise = require 'bluebird'
EPub = require 'epub'
sw = require 'stopword'
es = require '../database/es'
config = require '../../../config.json'

@read = (bookdir) =>
  return new Promise (rs, rj) =>
    epub = new EPub bookdir
    epub.on 'end', ->
      rs epub
    epub.parse()

@getTextWidth = (text, font, extW) =>
  @canvas ?= document.createElement('canvas')
  context = @canvas.getContext('2d')
  context.font = font
  metrics = context.measureText(text)
  extW ?= 0
  return metrics.width + extW

@getDifficult = (words) ->
  new Promise (rs, rj) ->
    results = []
    es.client.search
        index: config.es.dbs.ngram
        type: config.es.dbs.ngram
        requestTimeout: Infinity
        body:
          size: 1
          query:
            filtered:
              filter:
                and:
                  filters: [
                    {
                      terms: { word: words }
                    }
                  ]
      .then (resp) ->
        for hit in resp.hits.hits
          for word in words
            if hit._source.word is word
              results.push word
        rs results
      .catch (err) ->
        console.error err
        rj err

@getDifficultWords = (sentence) =>
  return new Promise (rs, rj) =>
    results = []
    words = sentence.replace(/[^\w\s]/gi, '').split(' ')
    words = sw.removeStopwords words
    # return rs words
    @getDifficult words
      .then (results) =>
        rs results
      .catch (err) =>
        rs words
    
module.exports = @