DataSettings = require 'views/data_settings'

class Settings extends Backbone.View
  tagName: 'div'
  className: 'settings'

  initialize: ->
    @dataSettings = new DataSettings { model: @model.get('dataSource'), channel: @model.get('channel') } if @model?
    if @model?
      @model.on 'change:height', @setHeight
      @setHeight()

  setHeight: =>
    @$el.css 'height', @model.get('height') - 20

  render: =>
    _.each [@dataSettings], (subSetting) =>
      @$el.append subSetting.render().el 
    @

module.exports = Settings