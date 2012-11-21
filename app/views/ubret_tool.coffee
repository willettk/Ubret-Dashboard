class UbretTool extends Backbone.View
  tagName: 'div'
  className: 'ubret-tool'
  nonDisplayKeys: ['id']
  noDataTemplate: require './templates/no_data'

  initialize: ->
    if @model?
      @model.on 'change:selectedElements', @toolSelectElements
      @model.on 'change:selectedKey', @toolSelectKey
      @model.get('filters').on 'add reset', @toolAddFilters
      @model.get('settings').on 'change', @passSetting
      @model.get('dataSource').on 'data-received', @render

    @$el.html @noDataTemplate()
    @$el.addClass @model.get('type')

    opts = 
      el: @$el
      selector: '#' + @id
      selectElementsCb: @selectElements
      selectKeyCb: @selectKey

    @tool = new Ubret[@model.get('type')](opts)
    @$el.attr 'id', @id

  render: =>
    if @model.get('dataSource').get('data').length is 0
      @$el.html @noDataTemplate()
    else
      @$el.find('.no-data').remove()
      opts =
        data: _.map(@model.get('dataSource').get('data').models, (datum) -> datum.toJSON())
        keys: @dataKeys(@model.get('dataSource').get('data').models)
        filters: @model.get('filters').models
        selectedElements: @model.get('selectedElements')?.slice()
        selectedKey: @model.get('selectedKey')

      @tool.setOpts opts
      @tool.start()

    @

  dataKeys: (data) =>
    dataModel = data[0].toJSON()
    keys = new Array
    for key, value of dataModel
      keys.push key unless key in @nonDisplayKeys
    Backbone.Mediator.publish("#{@model?.get('channel')}:keys", keys)
    return keys

  selectElements: (ids) =>
    @model.setElements ids

  selectKey: (key) =>
    @model.set 'selectedKey', key

  toolSelectKey: =>
    @tool?.selectKey @model.get('selectedKey')

  toolSelectElements: =>
    @tool?.selectElements @model.get('selectedElements').slice()

  toolAddFilters: =>
    @tool.addFilters @model.get('filters').toJSON()

  passSetting: =>
    @tool.receiveSetting key, value for key, value of @model.get('settings').changed

module.exports = UbretTool