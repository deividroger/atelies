mongoose            = require 'mongoose'
exports.start = (cb) ->
  require './globals'
  require './helpers/expressExtensions'
  require './helpers/languageExtensions'
  everyauth           = require 'everyauth'
  express             = require "express"
  http                = require "http"
  path                = require "path"
  app                 = express()
  everyauthConfig     = require './helpers/everyauthConfig'
  router              = require './routes/router'
  Postman             = require './models/postman'
  MongoStore          = require('connect-mongo')(express)
  config              = require './helpers/config'
  redirectUnlessSecure= require './helpers/middleware/redirectUnlessSecure'
  healthCheck         = require './helpers/middleware/healthCheck'

  sessionStore = new MongoStore url:config.connectionString
  if config.isProduction
    Postman.configure config.aws.accessKeyId, config.aws.secretKey
  else
    app.use express.errorHandler()
    app.locals.pretty = on
    if app.get("env") is 'development'
      app.use express.logger "dev"
      everyauth.debug = on
      if config.test.sendMail
        console.log "SENDING MAIL!"
        Postman.configure config.aws.accessKeyId, config.aws.secretKey
      else
        Postman.dryrun = on
    if app.get("env") is 'test'
      sessionStore = new express.session.MemoryStore()
      #app.use express.logger "dev"
      #everyauth.debug = on
      Postman.dryrun = on

  publicDir = path.join __dirname, '..', "public"
  global.DEBUG = !config.isProduction
  global.CONFIG = config
  global.STATIC_PATH = config.staticPath
  app.locals.secureUrl = config.secureUrl
  app.set "port", config.port
  app.set "views", path.join __dirname, "views"
  app.set "view engine", "jade"
  app.set 'domain', config.baseDomain
  app.use express.favicon path.join publicDir, 'images', 'favicon.ico'
  app.use "/isHealthy", healthCheck
  app.enable 'trust proxy'
  app.use redirectUnlessSecure
  #app.use express.compress() if config.isProduction #turned off as amazon already does this
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser config.appCookieSecret
  app.use express.session secret: config.appCookieSecret, store:sessionStore
  if app.get("env") isnt 'production'
    less = require 'connect-less'
    app.use less src: path.join(publicDir, '..'), debug: false, compress: config.isProduction
    app.use config.staticPath, express.static publicDir

  everyauthConfig.configure app
  app.use everyauth.middleware()
  connOptions =
    server: socketOptions: keepAlive: 1
    replset: socketOptions: keepAlive: 1
  mongoose.connect config.connectionString, connOptions
  mongoose.connection.on 'error', dealWith

  router.route app
  
  process.on 'exit', -> Postman.stop()

  server = http.createServer(app)
  if app.get("env") isnt 'production'
    server.sessionStore = sessionStore
    server.cookieSecret = config.appCookieSecret
  exports.server = server
  server.listen app.get("port"), ->
    console.log "Express server listening on port #{app.get("port")} on environment #{app.get('env')}"
    console.log "Mongo database connection string: #{config.connectionString}" if app.get("env") isnt 'production'
    cb(exports.server) if cb

exports.stop = ->
  exports.server.close()
  mongoose.connection.close()
  mongoose.disconnect()
