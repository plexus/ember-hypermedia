Tb.TsApiCache = Em.Object.extend
  cached: {}
  nonCacheable: ['/api/cart', '/api/customer', '/api/checkout']

  store: (resource, href)->
    href = @linkFor(resource) unless href
    return if _.isEqual(@get('cached')[href], resource)

    if @isCacheable(href)
      @get('cached')[href] = @promisify(resource, href)

  fetch: (href)->
    @get('cached')[href]

  contains: (href)->
    !!(@get('cached')[href])

  clear: ->
    @set('cached', [])

  linkFor: (resource)->
    if @hasSelfLink(resource)
      resource.link('self').get('href')
    else
      Em.String.dasherize(resource.toString())

  isCacheable: (href)->
    !@get('nonCacheable').contains(href)

  promisify: (resource, label)->
    if resource instanceof Em.RSVP.Promise
      resource
    else
      Em.RSVP.Promise.resolve(resource, label)

  hasSelfLink: (resource)->
    resource && resource.link && resource.link('self')

  toString: ->
    output = ''

    hrefs = Object.keys(@get('cached')).sort()

    output += href + "\n" for href in hrefs
    output.trim()
