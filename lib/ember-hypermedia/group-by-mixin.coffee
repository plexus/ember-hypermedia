groupBy = (groupBy) ->
  result = []
  @forEach (item) ->
    hasGroup = !!result.findBy('group', Ember.get(item, groupBy))
    unless hasGroup
      result.pushObject Ember.Object.create(
        group: Ember.get(item, groupBy)
        content: []
      )
    result.findBy('group', Ember.get(item, groupBy)).get('content').pushObject item
  result.mapBy('content')

EmHy.GroupBy = Ember.Mixin.create
  groupBy: groupBy

Array.prototype.groupBy = groupBy
