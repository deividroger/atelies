_         = require 'underscore'
Home      = require './home'
Account   = require './account'
Store     = require './store'
Admin     = require './admin'

exports.route = (app) ->
  env = app.get "env"
  domain = app.get 'domain'
  home = new Home env
  _.bindAll home
  store = new Store env, domain
  _.bindAll store
  account = new Account env
  _.bindAll account
  admin = new Admin env
  _.bindAll admin
  home.storeWithDomain = store.store
  #home
  app.get     "/",                                                          home.index domain
  app.get     "/blank",                                                     home.blank
  app.get     "/about",                                                     home.about
  app.get     "/terms",                                                     home.terms
  app.get     "/faq",                                                       home.faq
  app.get     "/technology",                                                home.technology
  app.get     "/iWantToBuy",                                                home.iWantToBuy
  app.get     "/iWantToSell",                                               home.iWantToSell
  app.get     "/contribute",                                                home.contribute
  app.get     "/donating",                                                  home.donating
  app.post    "/error",                                                     home.errorCreate
  #home search
  app.get     "/stores/search/:searchTerm",                                 home.storesSearch
  app.get     "/products/search/:searchTerm",                               home.productsSearch
  #account
  app.get     "/account",                                                   account.account
  app.get     "/account/registered",                                        account.registered
  app.get     "/account/mustVerifyUser",                                    account.mustVerifyUser
  app.get     "/account/verifyUser/:_id",                                   account.verifyUser
  app.get     "/account/verified",                                          account.verified
  app.get     "/account/orders/:_id",                                       account.order
  app.get     "/account/changePassword",                                    account.changePasswordShow
  app.post    "/account/changePassword",                                    account.changePassword
  app.get     "/account/passwordChanged",                                   account.passwordChanged
  app.get     "/account/updateProfile",                                     account.updateProfileShow
  app.post    "/account/updateProfile",                                     account.updateProfile
  app.get     "/account/profileUpdated",                                    account.profileUpdated
  app.get     "/account/forgotPassword",                                    account.forgotPasswordShow
  app.post    "/account/forgotPassword",                                    account.forgotPassword
  app.get     "/account/passwordResetSent",                                 account.passwordResetSent
  app.get     "/account/resetPassword",                                     account.resetPasswordShow
  app.post    "/account/resetPassword",                                     account.resetPassword
  app.post    "/account/resendConfirmationEmail",                           account.resendConfirmationEmail
  app.get     "/account/afterFacebookLogin",                                account.afterFacebookLogin
  app.get     "/notseller",                                                 account.notSeller
  #admin
  app.get     "/admin",                                                     admin.admin
  app.get     "/admin/orders",                                              admin.orders
  app.get     "/admin/orders/:_id",                                         admin.order
  #admin store
  app.post    "/admin/store",                                               admin.adminStoreCreate
  app.put     "/admin/store/:storeId",                                      admin.adminStoreUpdate
  app.put     "/admin/store/:storeId/setPagseguroOn",                       admin.adminStoreUpdateSetPagseguroOn
  app.put     "/admin/store/:storeId/setPagseguroOff",                      admin.adminStoreUpdateSetPagseguroOff
  #admin product
  app.get     "/admin/:storeSlug/products",                                 admin.storeProducts
  app.post    "/admin/:storeSlug/products",                                 admin.adminProductCreate
  app.get     "/admin/:storeSlug/products/:productId",                      admin.storeProduct
  app.put     "/admin/:storeSlug/products/:productId",                      admin.adminProductUpdate
  app.delete  "/admin/:storeSlug/products/:productId",                      admin.adminProductDelete
  #store order
  app.post    "/orders/:storeId",                                           store.orderCreate
  app.get     "/paymentGateway/pagseguro/:storeSlug/returnFromPayment",     store.pagseguroReturnFromPayment
  app.post    "/paymentGateway/pagseguro/:storeSlug/statusChanged",         store.pagseguroStatusChanged
  app.post    "/shipping/:storeSlug",                                       store.calculateShipping
  #store
  app.get     "/products/search/:storeSlug/:searchTerm",                    store.productsSearch
  app.get     "/:storeSlug",                                                store.store
  app.get     "/:storeSlug/:productSlug",                                   store.product
