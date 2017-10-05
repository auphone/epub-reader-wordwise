Importer = require './importer'

config = require '../config.json'
{ root, prefix, charCode } = config.es.importer.ngram

dbFiles = []

code = charCode.from - 1

while code++ < charCode.to
  letter = String.fromCharCode code
  dbFiles.push "#{root}/#{prefix}#{letter}"

class NgramImporter extends Importer
  
  constructor: (dbFiles, dbName) ->
    super dbFiles, dbName

  # Override
  splitEntry: (entry) ->
    cols = entry.split '\t'
    [ word, year, match_count, page_count ] = cols
    return null if word.indexOf('_') isnt -1
    return {
      word: word
      count: Number(match_count)
    }

  # Override
  duplicateCheck: (entries, record, lastRecord) ->
    if record?
      if lastRecord?.word is record.word
        entries[entries.length - 1]?.count += Number(record.count)
        return true
    return false


importer = new NgramImporter dbFiles, config.es.dbs.ngram
importer.run()