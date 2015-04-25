EmHy.FormField = Em.Object.extend(
  name: null
  type: null
  options: null
  _value: null
  enabled: true

  value: Em.computed 'type', 'options', (key, value, previousValue)->
    if arguments.length > 1
      if @get('type') is 'select'
        @get('options').forEach (option)->
          if option.get('value') == value
            option.set('selected', true)
          else
            option.set('selected', false)
      else
        @set('_value', value)

    if @get('type') is 'select'
      @get('options').findBy('selected')?.get('value')
    else
      @get('_value', value)

  makeLabel: (presenter) ->
    customLabel = @get('label')
    if customLabel
      if !presenter || presenter.isTranslatable(@)
        I18n.t(customLabel)
      else
        customLabel
    else
      @get('name').underscore().replace(/_/g, " ").capitalize()
)
