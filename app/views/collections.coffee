class Collections extends Backbone.View
  talkCollection: require 'collections/talk_collections'
  template: require './templates/collections'
  itemTemplate: require './templates/collection'
  manager: require 'modules/manager'

  initialize: ->
    @collection = new @talkCollection
    @collection.on 'add reset', @render

  loadCollection: =>
    @collection.fetch() if @manager.get('project')

  reset: =>
    @collection.reset()

  render: =>
    @$el.html @template()
    for model in @collection.formatModels()
      @$('.my-data-list').append @itemTemplate(model.toJSON()) 
    @

module.exports = Collections
