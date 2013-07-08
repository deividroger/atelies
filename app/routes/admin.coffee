Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
Order           = require '../models/order'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'
values          = require '../helpers/values'
correios        = require 'correios'
RouteFunctions  = require './routeFunctions'

class Routes
  constructor: (@env) ->
    @_auth 'admin'
    @_authSeller 'adminStoreCreate', 'adminStoreUpdate', 'adminProductUpdate', 'adminProductDelete', 'adminProductCreate', 'adminStoreUpdateSetAutoCalculateShippingOff', 'adminStoreUpdateSetAutoCalculateShippingOn', 'adminStoreUpdateSetPagseguroOff', 'adminStoreUpdateSetPagseguroOn', 'storeProduct', 'storeProducts'
  
  admin: (req, res) ->
    return res.redirect 'notseller' unless req.user.isSeller
    req.user.populate 'stores', (err, user) ->
      res.render 'admin', stores: _.map(user.stores, (s) -> s.toSimple())

  adminStoreCreate: (req, res) ->
    store = req.user.createStore()
    body = req.body
    store.name = body.name
    store.email = body.email
    store.description = body.description
    store.homePageDescription = body.homePageDescription
    store.homePageImage = body.homePageImage
    store.urlFacebook = body.urlFacebook
    store.urlTwitter = body.urlTwitter
    store.phoneNumber = body.phoneNumber
    store.city = body.city
    store.state = body.state
    store.zip = body.zip
    store.otherUrl = body.otherUrl
    store.banner = body.banner
    store.flyer = body.flyer
    store.autoCalculateShipping = body.autoCalculateShipping
    if body.pagseguro
      store.pmtGateways.pagseguro = {} unless store.pmtGateways.pagseguro?
      store.pmtGateways.pagseguro.email = body.pagseguroEmail
      store.pmtGateways.pagseguro.token = body.pagseguroToken
    store.save (err) ->
      return res.json 400, err if err?
      req.user.save (err) ->
        if err?
          store.remove()
          return res.json 400
        res.json 201, store
  
  adminStoreUpdate: (req, res) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      body = req.body
      store.name = body.name
      store.email = body.email
      store.description = body.description
      store.homePageDescription = body.homePageDescription
      store.homePageImage = body.homePageImage
      store.urlFacebook = body.urlFacebook
      store.urlTwitter = body.urlTwitter
      store.phoneNumber = body.phoneNumber
      store.city = body.city
      store.state = body.state
      store.zip = body.zip
      store.otherUrl = body.otherUrl
      store.banner = body.banner
      store.flyer = body.flyer
      store.save (err) ->
        if err?
          return res.json 400
        res.send 200, store
  adminStoreUpdateSetAutoCalculateShippingOff: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, off
  adminStoreUpdateSetAutoCalculateShippingOn: (req, res) -> @_adminStoreUpdateSetAutoCalculateShipping req, res, on
  _adminStoreUpdateSetAutoCalculateShipping: (req, res, autoCalculateShipping) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      store.setAutoCalculateShipping autoCalculateShipping, (set) ->
        if set
          store.save (err) ->
            return res.json 400 if err?
            res.send 204
        else
          res.send 409
  adminStoreUpdateSetPagseguroOff: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, off
  adminStoreUpdateSetPagseguroOn: (req, res) -> @_adminStoreUpdateSetPagseguro req, res, email: req.body.email, token: req.body.token
  _adminStoreUpdateSetPagseguro: (req, res, set) ->
    Store.findById req.params.storeId, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      store.setPagseguro set
      store.save (err) ->
        return res.json 400 if err?
        res.send 204

  adminProductUpdate: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      Store.findBySlug product.storeSlug, (err, store) ->
        dealWith err
        throw new AccessDenied() unless req.user.hasStore store
        product.updateFromSimpleProduct req.body
        product.save (err) ->
          res.send 204
  
  adminProductDelete: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      Store.findBySlug product.storeSlug, (err, store) ->
        dealWith err
        throw new AccessDenied() unless req.user.hasStore store
        product.remove (err) ->
          res.send 204
  
  adminProductCreate: (req, res) ->
    Store.findBySlug req.params.storeSlug, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      product = new Product()
      product.updateFromSimpleProduct req.body
      product.storeName = store.name
      product.storeSlug = store.slug
      product.save (err) ->
        res.send 201, product.toSimpleProduct()
  
  storeProducts: (req, res) ->
    Product.findByStoreSlug req.params.storeSlug, (err, products) ->
      dealWith err
      viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
      res.json viewModelProducts
  
  storeProduct: (req, res) ->
    Product.findById req.params.productId, (err, product) ->
      dealWith err
      if product?
        res.json product.toSimpleProduct()
      else
        res.send 404
  
_.extend Routes::, RouteFunctions::

module.exports = Routes