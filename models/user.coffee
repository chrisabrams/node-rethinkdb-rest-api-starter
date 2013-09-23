bcrypt = require 'bcrypt'
config = require '../config/default'
db     = require '../lib/db'
r      = require 'rethinkdb'

module.exports = class User

  authenticate: (data, callback) ->

    password = data.password
    username = data.username

    _this = @

    db.connect (err, connection) ->

      r.db(config.rethink.db).table('users').filter({username: username}).limit(1).run connection, (err, cursor) ->
        throw err if err

        # Step in and see if there is a user
        cursor.next (err, user) ->
          throw err if err

          # If there is no user
          if user.length is 0
            callback(err)

          # If there is a user
          else

            _this.validatePassword user, password, (isMatch) ->

              if isMatch

                callback(err, user)

              else

                callback(err)

        connection.close()

  create: (data, callback) ->

    email    = data.email
    password = data.password
    username = data.username

    _this = @

    @generateHash password, (hash) ->

      user =
        email: email
        hash: hash
        username: username

      db.connect (err, connection) ->

        r.db(config.rethink.db).table('users').insert(user).run connection, (err, result) ->

          if err
            console.log "[ERROR][%s][saveUser] %s:%s\n%s", connection["_id"], err.name, err.msg, err.message
            callback err

          else

            ###
            if result.inserted is 1
              callback null, user

            else
              callback null, false
            ###
            _this.authenticate data, callback

          connection.close()

  delete: (data, callback) ->

    db.connect (err, connection) ->

      r.db(config.rethink.db).table('users').get(data.id).delete().run connection, (err, response) ->

        callback(err, response)

        connection.close()

  generateHash: (password, callback) ->

    # generate a salt
    bcrypt.genSalt 10, (err, salt) ->
      throw err if err

      # hash the password using our new salt
      bcrypt.hash password, salt, (err, hash) ->
        throw err if err

        callback hash

  get: (id, callback) ->

    if typeof id is 'object'
      id = id.id # yes this is retarded

    db.connect (err, connection) ->

      r.db(config.rethink.db).table('users').get(id).run connection, (err, user) ->

        throw err if err

        callback(err, user)

        connection.close()

  update: (data, callback) ->

    _this = @

    db.connect (err, connection) ->

      r.db(config.rethink.db).table('users').get(data.id).update({email: data.email}).run connection, (err, result) ->

        _this.get data.id, callback

        connection.close()

  validatePassword: (user, password, callback) ->

    bcrypt.compare password, user.hash, (err, isMatch) ->
      throw err if err

      callback isMatch
