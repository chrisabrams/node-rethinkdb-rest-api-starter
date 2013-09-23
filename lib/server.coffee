__base = '..'

config  = require(__base + '/config/default')
restify = require 'restify'

server = restify.createServer
  name: config.rest.name
  version: config.rest.version

server.use(restify.acceptParser(server.acceptable))
server.use(restify.queryParser())
server.use(restify.bodyParser())
server.use(restify.CORS())
server.use(restify.fullResponse())

require(__base + '/routes')(server)

module.exports = server
