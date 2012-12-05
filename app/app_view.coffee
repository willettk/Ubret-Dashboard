User = require 'user'

BaseView = require 'views/base_view'

DashboardModel = require 'models/dashboard'
DashboardView = require 'views/dashboard'

AppHeader = require 'views/app_header'
Toolbox = require 'views/toolbox'

class AppView extends BaseView
  template: require './views/templates/layout/app'

  subscriptions:
    'dashboard:create': 'createDashboard'

  initialize: ->
    @appHeader = new AppHeader
    @toolbox = new Toolbox

    @$el.html @template()
    @render()

    @toolbox.on 'create', @addTool
    @toolbox.on 'remove-tools', @removeTools

  render: =>
    @assign
      '.app-header': @appHeader
      '.toolbox': @toolbox
    @

  createDashboard: (id) ->
    if typeof id is 'undefined'
      @dashboardModel = new DashboardModel
      @createDashboardView()
    else
      @dashboardModel = new DashboardModel { id: id }
      fetcher = @dashboardModel.fetch
      fetcher.success @createDashboardView

  createDashboardView: =>
    @dashboardView = new DashboardView { model: @dashboardModel, el: '.dashboard' }
    @dashboardView.render()

  toolboxEvents: =>
    @toolbox.on 'create', @addTool
    @toolbox.on 'remove-tools', @removeTools

  addTool: (toolType) =>
    @dashboardModel.createTool toolType

  removeTools: =>
    @dashboardModel.removeTools()
  
module.exports = AppView
