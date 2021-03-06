helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View yield, contentFor, and replace rendering'

asyncTest 'it should insert content into yields when the content comes before the yield', 1, ->
  source = '''
  <div data-contentfor="baz">chunky bacon</div>
  <div data-yield="baz" id="test">erased</div>
  '''
  node = helpers.render source, {}, (node) ->
    delay =>
      equals node.children(0).html(), "chunky bacon"

asyncTest 'it should insert content into yields when the content comes after the yield', 2, ->
  source = '''
  <div data-yield="baz" class="test">erased</div>
  <span data-contentfor="baz">chunky bacon</span>
  '''
  node = helpers.render source, {}, (node) ->
    delay =>
      equals node.children(0).html(), "chunky bacon"
      equal Batman.DOM._yieldContents["baz"], undefined, "_yieldContents was cleared"

asyncTest 'it should yield multiple contentfors that render into the same yield', ->
  source = '''
  <div data-yield="mult" class="test"></div>
  <span data-contentfor="mult">chunky bacon</span>
  <span data-contentfor="mult">spicy sausage</span>
  '''
  node = helpers.render source, {}, (node) ->
    delay =>
      equals node.children(0).first().html(), "chunky bacon"
      equals node.children(0).first().next().html(), "spicy sausage"

asyncTest 'it shouldn\'t go nuts if the content is already inside the yield', 1, ->
  source = '<div data-yield="baz" class="test">
              <span data-contentfor="baz">chunky bacon</span>
            </div>'
  node = helpers.render source, {}, (node) ->
    delay =>
      equals node.children(0).html(), "chunky bacon"

asyncTest 'it should render content even if the yield doesn\'t exist yet', 1, ->
  helpers.render '<div data-contentfor="foo">immediate</div>', {}, (content) ->
    helpers.render '<div data-yield="foo"></div>', {}, (node) ->
      delay =>
        equal node.children(0).html(), 'immediate'

asyncTest 'data-replace should replace content without breaking contentfors', 2, ->
  source = '''
    <div data-yield="foo">start</div>
    <div data-replace="foo">replaces</div>
    <div data-contentfor="foo">appends</div>
  '''
  helpers.render source, {}, (node) ->
    delay =>
      equal node.children(0).first().html(), 'replaces'
      equal node.children(0).first().next().html(), 'appends'

QUnit.module 'Batman.View rendering with bindings'

asyncTest 'it should update simple bindings when they change', 2, ->
  context = Batman foo: 'bar'
  node = helpers.render '<div data-bind="foo"></div>', context, (node) ->
    equals node.html(), "bar"
    context.set('foo', 'baz')
    equals node.html(), "baz"
    QUnit.start()

asyncTest 'it should allow chained keypaths', 3, ->
  context = Batman
    foo: Batman
      bar: Batman
        baz: 'wallawalladingdong'

  helpers.render '<div data-bind="foo.bar.baz"></div>', context, (node) ->

    equals node.html(), "wallawalladingdong"
    context.set('foo.bar.baz', 'kablamo')
    equals node.html(), "kablamo"
    context.set('foo.bar', Batman baz: "whammy")
    equals node.html(), "whammy"

    QUnit.start()
