path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'server'
    port: 3000
    db: 'mongodb://localhost/server-development'
    secret: 'DEVELOPMENT'

  test:
    root: rootPath
    app:
      name: 'server'
    port: 3000
    db: 'mongodb://localhost/server-test'
    secret: 'TEST'

  production:
    root: rootPath
    app:
      name: 'server'
    port: 3000
    db: 'mongodb://localhost/server-production'
    secret: 'PRODUCTION'

module.exports = config[env]
