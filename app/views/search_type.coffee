BaseView = require 'views/base_view'

class SearchType extends BaseView
  template: require './templates/search_type'

  events:
    'click li': 'onSelectType'
  initialize: ->
    @types = []

  set: (types) =>
    if _.isArray(types)
      @types = types
    else
      @types.push types

  render: =>
    @$el.html @template({types: @types})
    @

  # Events
  onSelectType: (e) =>
    type = $(e.currentTarget).data('type')
    @trigger 'searchType:typeSelected', type

module.exports = SearchType