requirejs.config
  paths:
    jquery: 'lib/jquery/jquery.min'
    underscore: 'lib/underscore/underscore-min'
    backbone: 'lib/backbone/backbone-min'
    handlebars: 'lib/handlebars/index'
    text: 'lib/requirejs-text/text'
    twitterBootstrap: 'lib/bootstrap/docs/assets/js/bootstrap.min'
    backboneValidation: 'lib/backbone-validation/dist/backbone-validation-amd-min'
    epoxy: 'lib/backbone.epoxy/index'
    caroufredsel: 'lib/carouFredSel/jquery.carouFredSel-6.2.1'
    imagesloaded: 'lib/imagesloaded/jquery.imagesloaded'
  shim:
    'handlebars':
      deps: ['jquery']
      exports: 'Handlebars'
    'underscore':
      exports: '_'
    'backbone':
      deps: ['underscore', 'jquery', 'handlebars']
      exports: 'Backbone'
    'twitterBootstrap':
      deps: ['jquery']
      exports: '$.fn.popover'
    'caroufredsel':
      deps: ['jquery']
      exports: '$.fn.carouFredSel'
    'imagesloaded':
      deps: ['jquery']
      exports: '$.fn.imagesLoaded'

if global? #nodejs only (tests)
  #needs to add jquery to global scope otherwise twitter bootstrap blows up
  window.$ = global.$ = requirejs 'jquery'
  #needs to call backbone config otherwise every test blows up
  requirejs './backboneConfig'
else
  requirejs [
    'app'
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], (App) ->
    App.start()
