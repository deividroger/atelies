webdriver       = require 'selenium-webdriver'
chromedriver    = require 'chromedriver'

webdriver.WebElement::type = (text) ->
  @clear().then => @sendKeys text

module.exports = class Page
  constructor: (url, page) ->
    [url, page] = [page, url] if url instanceof Page
    driver = page?.driver
    @url = url if url?
    if driver?
      @driver = driver
    else
      chromedriver.start()
      @driver = new webdriver.Builder()
        .usingServer('http://localhost:9515')
        .build()
      @driver.manage().timeouts().implicitlyWait 5000
  visit: (url) ->
    url = @url unless url?
    @driver.get "http://localhost:8000/#{url}"
  closeBrowser: (cb = (->)) ->
    stopDriver = ->
      chromedriver.stop()
      cb()
    @driver.quit().then stopDriver, cb
  errorMessageFor: (field) -> @getText "##{field} ~ .tooltip .tooltip-inner", cb
  errorMessageForSelector: (selector) -> @getText "#{selector} ~ .tooltip .tooltip-inner", cb
  errorMessagesIn: (selector, cb) -> @findElement(selector).findElements(webdriver.By.css('.tooltip-inner')).then (els) ->
    errorMsgs = {}
    flow = webdriver.promise.createFlow (f) =>
      for el in els
        do (el) ->
          f.execute =>
            el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
              el.getText().then (text) -> errorMsgs[id] = text
    flow.then (-> cb(errorMsgs)), cb

  findElement: (selector) -> @driver.findElement(webdriver.By.css(selector))
  clearCookies: (cb) -> @driver.manage().deleteAllCookies().then cb
  type: (selector, text) -> @driver.findElement(webdriver.By.css(selector)).type text
  check: (selector, cb = (->)) ->
    el = @driver.findElement webdriver.By.css(selector)
    el.isSelected().then (itIs) -> if itIs then process.nextTick cb else el.click().then cb
  uncheck: (selector, cb = (->)) ->
    el = @driver.findElement webdriver.By.css(selector)
    el.isSelected().then (itIs) -> if itIs then el.click().then cb else process.nextTick cb
  getText: (selector, cb) -> @driver.findElement(webdriver.By.css(selector)).getText().then cb
  getAttribute: (selector, attribute, cb) -> @driver.findElement(webdriver.By.css(selector)).getAttribute(attribute).then cb
  getValue: (selector, cb) -> @getAttribute selector, 'value', cb
  getIsChecked: (selector, cb) -> @driver.findElement(webdriver.By.css(selector)).isSelected().then cb
  pressButton: (selector, cb = (->)) -> @driver.findElement(webdriver.By.css(selector)).click().then cb
  clickLink: (selector, cb) -> @pressButton selector, cb
  currentUrl: (cb) -> @driver.getCurrentUrl().then cb
  hasElement: (selector, cb) -> @driver.isElementPresent(webdriver.By.css(selector)).then cb
  parallel: (actions, cb) ->
    flow = webdriver.promise.createFlow (f) =>
      for action in actions
        do (action) -> f.execute action
      undefined
    flow.then cb, cb
  waitForUrl: (url, cb) ->
    @driver.wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000
    cb()