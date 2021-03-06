define ['underscore'], (_) ->
  class Cart
    @_carts: null
    @clear: ->
      Cart._carts = null
      localStorage.clear()
    @get: (storeSlug) ->
      unless @_carts?
        @_carts = []
        @_carts.clear = -> cart.clear() for cart in @
      switch storeSlug
        when '' then throw message:'Cart needs a string'
        when undefined then return @_carts
      cart = _.findWhere @_carts, storeSlug: storeSlug
      unless cart?
        cart = new Cart storeSlug
        @_carts.push cart
      cart
    constructor: (@storeSlug) ->
      @_load()
    _items: []
    _load: ->
      @_items = []
      previousSessionItems = localStorage.getItem "cartItems#{@storeSlug}"
      if previousSessionItems?
        @_items = JSON.parse previousSessionItems
        @_constructItem item for item in @_items
    save: =>
      localStorage.setItem "cartItems#{@storeSlug}", JSON.stringify @_items
    addItem: (item) =>
      if existingItem = _.findWhere @_items, { _id: item._id }
        item = existingItem
        item.setQuantity item.quantity + 1
      else
        @_constructItem item
        item.setQuantity 1
        @_items.push item
      @save()
    _constructItem: (item) ->
      cart = @
      item.setQuantity = (q) ->
        cart._shippingOptions = undefined
        cart._shippingOptionSelected = undefined
        @quantity = q
        @totalPrice = @quantity * @price
    clear: =>
      @_items = []
      localStorage.removeItem "cartItems#{@storeSlug}"
    items: -> @_items
    removeById: (id) =>
      @_items = _.reject @_items, (item) -> item._id is id
      @save()
    totalPrice: ->
      total = _.chain(@_items)
        .map((i)->i.price*i.quantity)
        .reduce(((p, t) -> p+t), 0).value()
      total
    shippingCost: ->
      shippingOption = @shippingOptionSelected()
      if shippingOption?.cost? then shippingOption.cost else 0
    totalSaleAmount: -> @totalPrice() + @shippingCost()
    shippingOptions: -> @_shippingOptions
    shippingCalculated: -> if @hasShipping() then @_shippingOptions? else true
    shippingSelected: -> @_shippingOptionSelected?
    shippingOptionSelected: -> _.findWhere @_shippingOptions, type: @_shippingOptionSelected
    setShippingOptions: (opt) -> @_shippingOptions = opt
    chooseShippingOption: (type) ->
      opt = _.findWhere @_shippingOptions, type: type
      throw new Error("Shipping option does not exist.") unless opt?
      @_shippingOptionSelected = type
    choosePaymentType: (paymentType) -> @_paymentType = paymentType
    paymentTypeSelected: -> @_paymentType
    hasShipping: -> _.some @_items, (i) -> i.shippingApplies
