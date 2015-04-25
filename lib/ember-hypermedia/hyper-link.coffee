# Expects to have an attribute 'links' and an attribute 'subresources'

EmHy.HyperLink = Em.Object.extend
  rel: null
  href: null

  GET: (args...)->
    @api.load(@expand(args...))

  POST: (opts = {})->
    opts.method = 'POST'
    @api.load(@get('href'), opts)

  PUT: (opts = {})->
    opts.method = 'PUT'
    @api.load(@get('href'), opts)

  DELETE: (opts = {})->
    opts.method = 'DELETE'
    @api.load(@get('href'), opts)

  PATCH: (opts = {})->
    opts.method = 'PATCH'
    @api.load(@get('href'), opts)

  expand: (args...)->
    URI.expand(@get('href'), args...).toString()

  shortRel: Em.computed 'rel', ->
    @get('rel').replace(@api.relPrefix, '')
