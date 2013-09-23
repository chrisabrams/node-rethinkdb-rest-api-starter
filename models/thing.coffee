App    = require '../models/app'
bcrypt = require 'bcrypt'
config = require '../config/default'
db     = require '../lib/db'
r      = require 'rethinkdb'
_      = require 'underscore'

module.exports = class Thing

  @createOrUpdate: (data, callback) ->

    _this = @

    @getData app, data, (err, data) ->

      # Create
      if err

        @createData.apply _this, arguments

      # Update
      else

        @updateData.apply _this, arguments

  @get: (type, data, callback) ->

    switch type

      when 'channel'

        @getChannel.apply @, arguments

        break

      when 'data'

        @getData.apply @, arguments

        break

  createData: (data, callback) ->

    _this = @

    db.connect (err, connection) ->

      date = Date.now()

      filter = _.extend data,
        date:
          created: date
          updated: date
        owner_id: data.app_id
        type: 'data'

      if filter.app_id
        delete filter.app_id

      console.log "what is filter", filter

      r.db(config.rethink.db).table('things').insert(filter).run connection, (err, result) ->
        #throw err if err

        console.log "rethink ran args", arguments

        connection.close()

        data =
          id: result.generated_keys[0]

        _this.getData data, callback

  deleteData: (data, callback) ->

    db.connect (err, connection) ->

      r.db(config.rethink.db).table('things').get(data.id).delete().run connection, (err, response) ->

        callback(err, response)

        connection.close()

  getData: (data, callback) ->

    db.connect (err, connection) ->

      if data.id
        filter =
          id: data.id

      else

        if data.name

          filter =
            name: data.name
            owner_id: data.owner_id or data.app_id
            type: 'data'

        else
          return callback(true, null)

      r.db(config.rethink.db).table('things').filter(filter).limit(1).run connection, (err, cursor) ->
        #throw err if err

        if err
          return callback(err)

        # Step in and see if there is data
        cursor.next (err, data) ->
          #throw err if err

          # There is no data
          if err
            callback(err)

          # There is data
          else
            callback(err, data)

        connection.close()

  updateData: (pkg, callback) ->

    _this = @

    db.connect (err, connection) ->

      date = Date.now()

      filter =
        data: pkg.data
        date:
          updated: date

      # Create the channel
      r.db(config.rethink.db).table('things').get(pkg.id).update(filter).run connection, ->

        connection.close()

        _this.getData pkg, callback
