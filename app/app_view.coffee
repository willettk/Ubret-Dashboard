AppHeader = require 'views/app_header'
BaseView = require 'views/base_view'
DashboardView = require 'views/dashboard'
SavedList = require 'views/saved_list'
MyData = require 'views/my_data'
DashboardDialog = require 'views/dashboard_dialog'
BetaDialog = require 'views/beta_dialog'
User = require 'lib/user'

Manager = require 'modules/manager'
ToolLoader = require 'modules/tool_loader'
Tutorials = require 'tutorials'

DashboardModel = require 'models/dashboard'
Params = require 'collections/params'
ZooniverseSubjects = require 'collections/zooniverse_subjects'

Projects = require 'config/projects_config'

class AppView extends BaseView
  template: require 'views/templates/layout/app'
  loadingTemplate: require 'views/templates/loading'

  subscriptions:
    'dashboard:create' : 'createDashboardFromDialog'
    'dashboard:fork' : 'forkDashboard'
    'router:index' : 'index'
    'router:dashboardCreateFromCollection' : 'createDashboardFromCollection'
    'router:dashboardCreateFromZooids' : 'createDashboardFromZooids'
    'router:dashboardRetrieve' : 'loadDashboard'
    'router:viewSavedDashboards' : 'showSaved'
    'router:myData' : 'showMyData'

  initialize: ->
    @$el.html @template()

    if User.current?
      @showBetaDialog() unless User.current.prefs?.dashboard?.beta

    @appHeader = new AppHeader({el: @$('.app-header')})
    @dashboardView = new DashboardView
    @appHeader.switch.on 'project-change', @projectChange

    # Main area views. Switched out when appropriate.
    @appFocusView = null
    
    @state = 'landing'

  showBetaDialog: =>
    betaDialog = new BetaDialog()
    $('body').append betaDialog.render().el

  render: =>
    if @state is 'landing' and not User.current?.prefs?.dashboard?.welcome_tut
      if User.current? 
        Tutorials.landing.steps.welcome.details = "Follow this tutorial to get started using Dashboard."
      tutorial = Tutorials.landing
      tutorial.el.bind('end-tutorial', @endTutorial)
      tutorial.start()
    @state += 1
    
    unless @appFocusView?
      @assign
        '.app-header': @appHeader
    else
      @assign
        '.app-header': @appHeader
        '.main-focus': @appFocusView
    @

  index: =>
    @$('.main-focus').empty()
    @appFocusView = null
    @render()

  projectChange: =>
    User.current?.dashboards.reset()
    User.current?.getDashboards()
    delete @dashboardModel
    Manager.get('router').navigate("#/dashboards/#{Manager.get('project')}", {trigger: true})

  endTutorial: =>
    data = JSON.stringify({key: 'dashboard.welcome_tut', value: true})
    url = Manager.baseApi() + "/users/preferences"
    User.current.setPrefs(data, url)

  loadUbretTools: =>
    ToolLoader @dashboardModel, @createDashboardView

  forkDashboard: =>
    @dashboardModel.fork().done (response) =>
      @dashboardModel = new DashboardModel response
      @navigateToDashboard()

  createDashboardFromDialog: =>
    dashboardDialog = new DashboardDialog { parent: @ }
    $('body').append dashboardDialog.render().el
    dashboardDialog.$el.find('input').first().focus()

  createTools: (tools, dataSource) ->
    toolsFormat = []
    _.each(tools, (toolType, index) ->
      tool = 
        tool_type: toolType
        name: "#{toolType}-#{index}"
        data_source: dataSource
      toolsFormat.push tool)
    toolsFormat

  createDashboard: (name, tools=[], project=null) ->
    Manager.set 'project', project if project
    new DashboardModel
      name: name
      project: (project or Manager.get('project'))
      tools: tools

  createDashboardFromZooids: (name, zooids) ->
    params = [ {key: 'zoo_ids', val: []} ]

    dataSource = 
      source_type: 'zooniverse'
      params: params

    dataTool = @createTools(['Zooniverse'], dataSource)
    @dashboardModel = @createDashboard(name, dataTool)
    
    @dashboardModel.save('tools[0].data_source.params[0].val', zooids).done (response) =>
      id = response.tools[0]._id

      dataSource = 
        source_type: 'internal'
        source_id: id

      toolset = Projects[Manager.get('project')].defaults
      tools = @createTools(toolset, dataSource)
      @dashboardModel.get('tools').set tools
      @dashboardModel.save().done =>
        @navigateToDashboard()

  createDashboardFromCollection: (name, collection) =>
    new ZooniverseSubjects([], {type: 'collection', id: collection})
      .fetch().then((collection) =>
        zooIDs = _.map collection.subjects, (s) -> s.zooniverse_id
        @createDashboardFromZooids(name, zooIDs))

  loadDashboard: (id) =>
    @$('.main-focus').html @loadingTemplate()
    @dashboardModel = new DashboardModel {id: id}
    @state = 'create-dashboard'
    @dashboardModel.fetch().then @loadUbretTools, =>
      delete @dashboardModel
      Manager.get('router').navigate '', {trigger: true}

  switchView: (view) =>
    @appFocusView?.$el.empty()
    @appFocusView = view
    @render()

  createDashboardView: =>
    tutorialEligiable = not User.current?.projectPrefs(@dashboardModel.get('project_id'))?.tutorial? 
    tutorialEligiable = tutorialEligiable and not (@dashboardModel.get('name') is 'Tutorial')
    if tutorialEligiable and Tutorials[Manager.get('project')]?
      @startTutorial()
    Backbone.Mediator.publish 'dashboard:initialized', @dashboardModel
    @switchView(@dashboardView)

  showSaved: =>
    unless @savedListView? 
      @savedListView = new SavedList 
        collection: User.current.dashboards
    @switchView(@savedListView)
    User.current.getDashboards()

  showMyData: =>
    unless @myDataView? then @myDataView = new MyData
    @myDataView.loadCollections()
    @switchView(@myDataView)

  navigateToDashboard: (trigger=true) =>
    url = "#/dashboards/#{Manager.get('project')}/#{@dashboardModel.id}"
    Manager.get('router').navigate url, {trigger: trigger}

  startTutorial: =>
    @dashboardModel = @createDashboard('Tutorial', [], null)
    @dashboardModel.save().then =>
      @navigateToDashboard()

module.exports = AppView
