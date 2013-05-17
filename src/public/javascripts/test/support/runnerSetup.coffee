path    = require 'path'
fs      = require 'fs'

process.addListener 'uncaughtException', (error) -> console.log "Error happened:\n#{error.stack}"

# set up require.js to play nicely with the test environment
global.requirejs = require "requirejs"
requirejs.config
  baseUrl: "."
  nodeRequire: require
  paths:
    text: 'lib/text'
    jquery: 'lib/jquery.min'
    backboneModelBinder: 'lib/Backbone.ModelBinder'
    backboneValidation: 'lib/backbone-validation-amd-min'
    twitterBootstrap: 'lib/bootstrap.min'
  shim:
    'backboneModelBinder':
      deps: ['backbone']
    'twitterBootstrap':
      deps: ['jquery']
      exports: '$.fn.popover'

# Test helper: set up a faux-DOM for running browser tests
initDOM = ->
  # Create a DOM
  jsdom = require("jsdom")
  # Create window
  global.window = window = jsdom.jsdom().createWindow("<html><body></body></html>")
  # create a jQuery instance
  window.XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
  window.XMLHttpRequest.prototype.withCredentials = false
  global.location = window.location
  global.navigator = window.navigator
  global.XMLHttpRequest = window.XMLHttpRequest
  global.jQuery = global.$ = jQuery = requirejs 'jquery'

  # Set up global references for DOMDocument+jQuery
  global.document = window.document
  # add addEventListener for coffeescript compatibility:
  global.addEventListener = window.addEventListener
  unless window.localStorage?
    LocalStorage = require('node-localstorage').LocalStorage
    window.localStorage = new LocalStorage(path.join __dirname, '.localstorage-test')
    global.localStorage = window.localStorage

# Test helper: set up Backbone.js with a browser-like environment
global.initBackbone = ->
  # Get a headless DOM ready for action
  initDOM()
  # tell backbone to use jQuery
  require("backbone").$ = jQuery
  global.Backbone = require("backbone")
  global._ = require("underscore")
  requirejs 'twitterBootstrap'

initBackbone()
require '../../../../test/support/_specHelper'