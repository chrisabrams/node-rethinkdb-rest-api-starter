module.exports =

  rest:
    name: 'node-rethinkdb-rest-api-starter'
    port: 3031
    version: '0.0.1'

  rethink:
    db: process.env.RDB_DB or 'example'
    host: process.env.RDB_HOST or 'localhost'
    port: parseInt(process.env.RDB_PORT) or 28015
    tables:
      things: 'id'
      users: 'id'
