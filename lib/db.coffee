assert   = require 'assert'
config   = require '../config/default'
r        = require 'rethinkdb'
util     = require 'util'

module.exports =

  connect: (callback) ->

    r.connect
      host: config.rethink.host
      port: config.rethink.port
    , (err, connection) ->
      assert.ok err is null, err
      connection["_id"] = Math.floor(Math.random() * 10001)
      callback err, connection

  setup: ->

    r.connect
      host: config.rethink.host
      port: config.rethink.port
    , (err, connection) ->
      assert.ok err is null, err

      r.dbCreate(config.rethink.db).run connection, (err, result) ->
        
        for tbl of config.rethink.tables

          ((tableName) ->

            r.db(config.rethink.db).tableCreate(tableName,
              primaryKey: config.rethink.tables[tbl]
            ).run connection, (err, result) ->

          ) tbl  
