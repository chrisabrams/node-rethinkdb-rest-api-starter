__base        = __dirname + '/..'
__common      = __base
__controllers = __common + '/controllers'
__models      = __common + '/models'

Controller = require __controllers + '/_base'
Thing      = require __models + '/thing'

module.exports = class ThingsController extends Controller

  @create: (pkg) ->

    thing = new Thing

    # save thing to database
    thing.createData pkg, (err, thing) =>
      console.log "thing created", arguments
      #throw err if err

      if err
        response =
          error: err

      else

        response =
          pkg:
            thing: thing
          status: 'success'

      this.send '/things/create', response

  @delete: (pkg) ->

    thing = new Thing

    thing.deleteData pkg, (err) =>

      if err
        response =
          error: 'nope'

      else
        response =
          action: 'deleted'
          status: 'success'

      this.send '/things/delete', response

  @get: (pkg) ->

    thing = new Thing

    thing.getData pkg, (err, thing) =>

      if err
        response =
          error: err

      else
        response =
          pkg:
            thing: thing
          status: 'success'

      this.send '/things/get', response

  post: (req, res, next) ->

    Thing.createOrUpdate req.params, (err, thing) ->

      if err
        response =
          error: err
          status: 'error'

      else

        response =
          pkg:
            thing: thing

      @send(response)

  @update: (pkg) ->

    thing = new Thing

    thing.updateData pkg, (err, thing) =>

      if err
        response =
          error: err

      else
        response =
          pkg:
            thing: thing
          status: 'success'

      this.send '/things/update', response
