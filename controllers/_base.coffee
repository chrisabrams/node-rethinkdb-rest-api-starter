module.exports = class Controller

  @response: null
  @type: null

  @send: (path, res) ->

    if @type is 'socket'
      @response.emit "api:/#{path}", res

    # Restify
    else
      @response.send res

  @set: (key, val) ->

    if key and val
      @[key] = val
