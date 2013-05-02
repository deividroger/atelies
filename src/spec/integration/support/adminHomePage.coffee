module.exports = class AdminCreateStorePage
  constructor: (@browser) ->
  visit: (cb) => @browser.visit "http://localhost:8000/admin", cb
  createStoreLinkText: => @browser.text("#createStore")
  rows: => @browser.query('#stores tbody')?.children
  storesQuantity: =>
    rows = @rows()
    if rows? then rows.length else 0
  stores: =>
    rows = @rows()
    stores = []
    for row in rows
      store.push url: row
    stores