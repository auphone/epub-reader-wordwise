es = require '../database/es'
config = require '../../../config.json'

@translateWords = (words) ->
  return new Promise (rs, rj) ->
    results = []
    es.client
      .search
        size: 10000
        index: config.es.dbs.cedict
        type: config.es.dbs.cedict
        requestTimeout: Infinity
        body:
          size: 1
          query:
            terms:
              'english': words
      .then (resp) ->
        for hit in resp.hits.hits
          for word in words
            if hit._source.english is word
              results.push hit._source
        rs results
      .catch (err) ->
        console.error err
        rj err
  
module.exports = @