EmHy.HasFields = Em.Mixin.create
  # These are the raw field data, use formFields to get proper
  # FormField instances
  fields: []

  formFields: Em.computed 'fields', ->
    @generateFields()

  generateFields: ->
    @get('fields').map (field)=>
      if field.type is 'fieldset'
        @container.lookupFactory('emhy:form-fieldset').create(field)
      else
        fieldProps = field
        if field.type == 'select'
          options = field.options.map (option)=>
            @container.lookupFactory('emhy:form-field-option').create(option)
          fieldProps = _({}).extend(fieldProps, {options: options})
        @container.lookupFactory('emhy:form-field').create(fieldProps)

  resetFields: ->
    @set('formFields', @generateFields())

  values: (->
    obj = {}

    @forEachField (field)->
      if field.get('enabled')
        obj[field.get('name')] = field.get('value')

    obj
  ).property().volatile()

  forEachField: (callback)->
    @get('formFields').forEach (field)->
      if EmHy.HasFields.detect(field)
        field.forEachField(callback)
      else
        callback(field)

  findFieldByName: (name)->
    found = []

    @forEachField (field)=>
      if field.get('name') is name
        found.pushObject(field)

    found
