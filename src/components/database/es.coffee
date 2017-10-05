Promise = require 'bluebird'
es = require 'elasticsearch'
fs = require 'fs'
config = require '../../../config.json'

@connect = =>
  return new Promise (rs, rj) =>
    @client = new es.Client
      hosts: config.es.host
      log: null
    rs @client

exports = @