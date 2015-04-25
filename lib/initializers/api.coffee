Ember.Application.initializer
  name: 'api'

  initialize: (container, application)->
    application.register('tb:ts-api', Tb.TsApi)
    application.register('tb:ts-api-cache', Tb.TsApiCache)
    application.inject('controller', 'api', 'tb:ts-api')
    application.inject('model', 'api', 'tb:ts-api')
    application.inject('route', 'api', 'tb:ts-api')
    prepopulateLinkCache(container)

prepopulateLinkCache = (container)->
  accountJson = document.getElementById('account_json')
  showsJson   = document.getElementById('shows_json')
  create      = (type, content)-> container.lookupFactory(type).create(JSON.parse(content))
  api         = container.lookup('tb:ts-api')
  cache       = container.lookup('tb:ts-api-cache')

  if accountJson
    account = create('model:account', accountJson.innerHTML)
    cache.store(new Em.RSVP.resolve(account), '/api')
  if showsJson
    shows = create('model:collection_resource', showsJson.innerHTML)
    cache.store(new Em.RSVP.resolve(shows), '/api/shows')
