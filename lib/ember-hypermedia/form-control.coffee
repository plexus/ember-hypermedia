#= require './has_fields'

EmHy.FormControl = Em.Object.extend(
  EmHy.HasFields

  name: null
  href: null
  method: null
  title: null

  mediaType: Em.computed.alias 'media_type'

  submit: (extraVals = {}) ->
    onError = extraVals.onError
    metadata = extraVals.metadata
    values = _(@get('values')).extend(extraVals)
    delete extraVals.onError
    delete extraVals.metadata

    @api.load(@get('href'),
      method: @get('method'),
      headers:
        'Content-Type': @get('mediaType')
      body: @encodeBody(values),
      onError: onError,
      metadata: metadata
    )

  encodeBody: (values) ->
    if @get('media_type') == 'application/x-www-form-urlencoded'
      formurlencoded.encode(values)
    else
      JSON.stringify(values)
)
