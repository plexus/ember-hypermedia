EmHy.LinkCollection = Em.Object.extend(
  Em.Array

  init: ->
    @_super()
    @set('content', Em.A()) unless @get('content')

  objectAt: (index) ->
    @get('content')[index]

  length: Em.computed.alias('content.length')

  push: (link) ->
    @set(link.get('shortRel'), link)
    @get('content').push(link)

  byRel: (rel) ->
    @filterBy('rel', rel)
)
