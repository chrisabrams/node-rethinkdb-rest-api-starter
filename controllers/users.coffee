__base        = __dirname + '/..'
__common      = __base
__controllers = __common + '/controllers'
__models      = __common + '/models'

Controller = require __controllers + '/_base'
User       = require __models + '/user'

module.exports = class UsersController extends Controller

  @authenticate: (pkg) ->

    # attempt to authenticate user
    user = new User

    user.authenticate pkg, (err, user) =>

      # login was successful if we have a user
      if user

        response =
          pkg:
            user: user
          status: 'success'

      else

        response =
          error:
            code: err.code
            message: 'Login failed.'

      this.send '/users/authenticate', response

  @create: (pkg) ->

    user = new User

    # save user to database
    user.create pkg, (err, user) =>

      #throw err if err

      if err

        switch err.code

          when 11000
            error =
              code: err.code
              message: 'Username is already taken.'

            break

        response =
          error: error

      else

        response =
          pkg:
            user: user
          status: 'success'

      this.send '/users/create', response

  @delete: (pkg) ->

    user = new User

    user.delete pkg, (err) =>

      if err
        response =
          error: 'nope'

      else
        response =
          action: 'deleted'
          status: 'success'

      this.send '/users/delete', response

  @get: (pkg) ->

    user = new User

    user.get pkg, (err, user) =>

      if err
        response =
          error: err

      else
        response =
          pkg:
            user: user
          status: 'success'

      this.send '/users/get', response

  @update: (pkg) ->

    user = new User

    user.update pkg, (err, user) =>

      if err
        response =
          error: err

      else
        response =
          pkg:
            user: user
          status: 'success'

      this.send '/users/update', response
