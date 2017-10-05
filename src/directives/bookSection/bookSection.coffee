$ = require 'jquery'
Promise = require 'bluebird'
reader = require '../../components/reader/reader'
translator = require '../../components/translate/translator'

angular
  .module 'app'
  .directive 'bookSection', class
    @$inject: [ ]
    constructor: ->
      return obj =
        scope:
          book: '='
          chapter: '='
        link: (scope, element) =>
          init = =>
            scope.tmap = {}
            getChapter scope.chapter.id
              .then (html) ->
                writeHTML html
              .then ->
                return getPageMeta()
              .then (meta) ->
                scope.meta = meta
                return getPars()
              .then (pars) ->
                scope.pars = pars
                Promise.each pars, (p) ->
                  return translatePar p
              .then ->
                toSentenses scope.pars
              .then (sentences) ->
                html = ""
                for line in sentences
                  html += "<p>#{line}</p>"
                writeHTML html
          
          # Get Chapter
          getChapter = (id) ->
            return new Promise (rs, rj) ->
              scope.book.getChapter id, (err, text) ->
                return rj err if err?
                rs text

          # Write HTML
          writeHTML = (html) ->
            return new Promise (rs, rj) ->
              $(element).html html
              setTimeout ->
                rs()
              , 500

          # Get Page Meta
          getPageMeta = ->
            font = $(element).css('font')
            bodyWidth = $('body').width()
            return {
              font: font
              width: bodyWidth
            }

          # Get Paragraphs
          getPars = ->
            return new Promise (rs, rj) ->
              pars = []
              $(element)
                .find('p')
                .each (idx, ele) ->
                  pars.push $(ele).text()
              rs pars

          # Translate Par
          translatePar = (p) ->
            return new Promise (rs, rj) ->
              reader.getDifficultWords p
                .then (words) ->
                  dWords = []
                  for w in words when not scope.tmap[w]?
                    dWords.push w
                  return translator.translateWords dWords
                .then (translates) ->
                  for translate in translates
                    { english, traditional } = translate
                    if not scope.tmap[english]?
                      scope.tmap[english] = traditional
                  rs()

          # To Sentences
          toSentenses = (pars) ->
            return new Promise (rs, rj) ->
              { width, font } = scope.meta
              sentences = []
              Promise
                .each pars, (p) ->
                  tmp = ""
                  chinese = ""
                  texts = p.split(' ')
                  for txt in texts
                    if reader.getTextWidth(tmp + txt, font) > width
                      sentences.push chinese
                      sentences.push tmp
                      tmp = ""
                      chinese = ""
                    else
                      senW = reader.getTextWidth tmp, font, 10
                      chinese += " " if chinese isnt ""
                      chinese += """
                        <span style='left: #{senW}px'>
                          #{scope.tmap[txt] ? ""}
                        </span>
                      """
                      tmp += " " if tmp isnt ""
                      tmp += txt
                  if tmp isnt ""
                    sentences.push chinese
                    sentences.push tmp
                  return Promise.resolve()
                .then ->
                  rs sentences

          init()