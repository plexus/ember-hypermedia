#= require underscore/underscore
#= require uri

Ticketbooth.TsApi = Ember.Object.extend
  relPrefix: 'http://api.ticketsolve.com/rel/'
  profilePrefix: 'http://api.ticketsolve.com/profile/'
  cache: null
  successHooks: []
  failureHooks: []

  init: ->
    @set('cache', @container.lookup('tb:ts-api-cache'))

  rel: (type)->
    @get('relPrefix') + type

  shortRel: (rel)->
    rel.replace(@get('relPrefix'), '') if rel

  addSuccessHook: (hook)->
    @get('successHooks')[@get('successHooks').length] = hook

  addFailureHook: (hook)->
    @get('failureHooks')[@get('failureHooks').length] = hook

  collectionModel: (rel)->
    type = 'collection_resource'
    type = 'line_item_collection' if @shortRel(rel) == 'line_items'
    @container.lookupFactory("model:" + type)

  modelForProfile: (profiles)->
    baseModel = @container.lookupFactory("model:base_model")
    return baseModel unless profiles

    shortProfile = profiles[0]
    shortProfile = @modelForCollection(profiles) if shortProfile == 'collection'

    @container.lookupFactory("model:" + shortProfile) or baseModel

  modelForCollection: (profiles)->
    if profiles.length > 1 && profiles[0] == 'collection'
      profiles[1] + '_collection'
    else
      'collection_resource'

  coerceNestedCollection: (result, rel)->
    @collectionModel(rel).create
      count:   result.length
      content: result.map(@coerceResults.bind(@))

  extractProfiles: (result)->
    if result._links?.profile?
      @toShortProfiles(result._links.profile)

  toShortProfiles: (profiles)->
    profiles.map (profile)=> profile.href.replace(@get('profilePrefix'), '')

  coerceResults: (result, rel)->
    return unless result

    if _.isArray(result)
      return @coerceNestedCollection(result, rel)

    profiles = @extractProfiles(result)
    model    = @modelForProfile(profiles)

    instance = model.create(result)
    @get('cache').store(instance)
    @handleInvalidations(instance)
    instance

  unwrapError: (response)->
    throw @coerceResults(response.jqXHR.responseJSON)

  fireSuccessHooks: (result, metadata)->
    @get('successHooks').forEach (hook)->
      hook(result, metadata)

  fireFailureHooks: (result, metadata)->
    @get('failureHooks').forEach (hook)->
      hook(result, metadata)

  # Options
  # - method:  HTTP method, 'GET', 'POST', etc.
  # - headers: Extra HTTP headers for the request
  # - body:    Request body (raw string)
  # - data:    Request body as JS object, will be rendered as JSON
  # - onError: Handler for error responses. This will be called before the "failure hooks"
  #            fire. If a handler is supplied, and it is not able to adequately handle a
  #            given exception, it should return a rejecting promise, so that it propagates
  #            to the generic failure handlers
  #
  load: (href, opts = {}) ->
    return @get('cache').fetch(href) if @get('cache').contains(href)

    method = opts.method || 'GET'
    onError = opts.onError || (e)-> Em.RSVP.reject(e)
    metadata = opts.metadata || {}

    headers = _({
      'Accept': 'application/halo+json, application/json, */*; q=0.01',
      'X-CSRF-Token': Ember.$('meta[name="csrf-token"]').attr('content')
    }).extend(opts.headers || {})

    ajax_opts =
      url: href
      type: method
      headers: headers
      dataType: 'json' # what we expect back from the server

    if opts.body
      ajax_opts.data = opts.body
    else if opts.data
      ajax_opts.data = JSON.stringify(opts.data)

    promise = ic.ajax.request(ajax_opts)
    result = promise.then(@coerceResults.bind(@), @unwrapError.bind(@), 'coerce API result')

    @get('cache').store(result, href) if method is 'GET'

    # Function wrapper added to use the metadata information in our hooks.
    fireSuccessHooks = (result)=> @fireSuccessHooks.bind(@)(result, metadata)
    fireFailureHooks = (result)=> @fireFailureHooks.bind(@)(result, metadata)

    result.then(fireSuccessHooks, onError, 'fire API hooks')
      .catch(fireFailureHooks, 'fire API failure hooks')

    result

  handleInvalidations: (resource) ->
    links = resource.get('links').byRel('invalidates')
    if links
      for link in links
        href = link.get('href')
        atoms = Tb.Atom.instances.filterBy('selfLink', href)
        unless _.isEmpty(atoms)
          link.GET().then (new_resource) ->
            for atom in atoms
              atom.set('content', new_resource)

  root: ->
    @load "/api"

  find: (type, id) ->
    @root().then (account) ->
      account.link(type).GET(id: id)
    , null, 'Ticketbooth.account()'
