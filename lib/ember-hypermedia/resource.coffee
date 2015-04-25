#= require './group_by_mixin'

EmHy.Resource = Em.Mixin.create
  init: ->
    @_super()
    @set('prefixes', ['', @api?.relPrefix])
    @set('_links', {}) unless @get('_links')
    @set('_embedded', {}) unless @get('_embedded')
    @set('_controls', {}) unless @get('_controls')

  # Return a linked resource. The resource can be an embedded subresource, or a  linked resource.
  # In either case a promise that resolves to the resource is returned.
  #
  # @example
  #   this.resource('venues').then(function(venues) {}, function(error) {})
  resource: (rel)->
    return Em.RSVP.resolve(@get('embedded').get(@api.shortRel(rel))) if @get('embedded').get(@api.shortRel(rel))
    return @link(rel).GET() if @link(rel)

  realize: (rel)->
    @resource(rel).then (resource)=>
      @set(rel, resource)

  # "Emberified" version of "_embedded", to get a non-promise version when you are sure the resource
  # is embedded and not linked.
  #
  # @example
  #   this.get('embedded.venues')
  embedded: Em.computed '_embedded', ->
    result = Em.Object.create()
    for rel, obj of @get('_embedded')
      shortRel = rel.replace(@api.relPrefix, '')
      result.set(shortRel, @api.coerceResults(obj, rel)) if obj
    result

  # An array of hyperlink objects
  links: Em.computed '_links', ->
    result = @container.lookupFactory('emhy:link-collection').create()
    for rel, link of @get('_links')
      if link
        if _.isArray(link)
          link.forEach (l)=> result.push(@container.lookupFactory('emhy:hyper-link').create(Em.merge(l, rel: rel)))
        else
          result.push(@container.lookupFactory('emhy:hyper-link').create(Em.merge(link, rel: rel)))
    result

  forms: Em.computed.alias('controls')
  controls: Em.computed '_controls', ->
    result = Em.Object.create()
    for rel, control of @get('_controls')
      shortRel = rel.replace(@api.relPrefix, '')
      result.set(shortRel, @container.lookupFactory('emhy:form-control').create(control))
    result

  # Find a link by rel. Returns a HyperLink.
  #
  # @example
  #   this.link('venues').GET().then(function (venues) {})
  link: (rel, args...)->
    @get('links').find (link) =>
      (link.get('rel') is rel) or (link.get('shortRel') is rel)
