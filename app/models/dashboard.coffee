Tools = require 'collections/tools'
Tool = require  'models/tool'
Sources = require 'collections/sources'
User = require 'user'
corsSync = require 'sync'

class Dashboard extends Backbone.Model
  urlRoot: '/dashboards'

  sync: corsSync

  parse: (response) =>
    @tools['dashboardId'] = response.id
    @tools.fetch
      success: => @resetCount()
    response

  initialize: ->
    @tools = new Tools
    @save().success(=> 
      User.current.updateDashboards @id, @get('name')
      Backbone.Mediator.publish 'dashboard:initialized', @
      @resetCount()) if typeof @id is 'undefined'

  createTool: (toolType) =>
    name = @namer toolType
    @tools.add 
      type: toolType 
      name: name
      channel: name

  toJSON: ->
    json = new Object
    json[key] = value for key, value of @attributes
    json['tools'] = tool.id for tool in @tools.toJSON if @tools.length > 0
    json

  resetCount: =>
    @count = @tools.length + 1

  namer: (type) =>
    name = "#{type}-#{@count}"
    console.log name
    tool = @tools.filter (tool) ->
      tool.get('name') is name
    if tool.length isnt 0
      @count = @count + 1
      @namer type
    else
      name

  removeTools: =>
    @tools.each (tool) -> tool.destroy()
    @resetCount()
    @save()

module.exports = Dashboard