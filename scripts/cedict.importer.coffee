Importer = require './importer'

config = require '../config.json'
{ root, filename } = config.es.importer.cedict
dbFiles = ["#{root}#{filename}"]

class CEDITImporter extends Importer
  
  constructor: (dbFiles, dbName) ->
    super dbFiles, dbName

  # Override
  splitEntry: (entry) ->
    firstSpace = entry.indexOf ' '
    secondSpace = entry.indexOf ' ', firstSpace + 1
    leftBracket = entry.indexOf '['
    rightBracket = entry.indexOf ']'
    firstSlash = entry.indexOf '/'
    lastNonSlashChar = entry.length - 2
    traditional = entry.substr 0, firstSpace
    simplified = entry.substr firstSpace + 1, secondSpace - firstSpace - 1
    pinyin = entry.substr leftBracket + 1, rightBracket - leftBracket - 1
    english = entry.substr firstSlash + 1, lastNonSlashChar - firstSlash

    return {
      traditional: traditional
      simplified: simplified
      pinyin: pinyin
      english: english
    }

importer = new CEDITImporter dbFiles, config.es.dbs.cedict
importer.run()