Spine = require 'spine'

class DataSettings extends Spine.Controller
  events:
    'click .data-sources li'    : 'onDataSourceSelection'
    'click button[name="fetch"]': 'fetchData'

  elements: 
    '.source-choices'           : 'sourceData'
    '.data-points'              : 'dataPoints'
    '.submit'                   : 'submit'
    'input[name="params"]'      : 'params'
    'input[name="identifier"]'  : 'identifier'
    '.source-data-box'          : 'sourceDataBox'

  template: require('views/data_settings')

  constructor: ->
    super

  render: =>
    @html @template(@)

  onDataSourceSelection: (e) =>
    @sourceItem = $(e.currentTarget)
    @sourceItem.addClass 'selected'
    @sourceItem.siblings().removeClass 'selected'

    @source = @sourceItem.data('source')

    @sourceData.empty()

    if @source is 'api'
      @sourceData.append(require('views/data_settings_sources')(@))
      @dataPoints.show()
    else
      @sourceData.append(require('views/data_settings_channel')(@))
      @dataPoints.hide()

    @sourceDataBox.show()
    @submit.show()

  fetchData: (e) =>
    e.preventDefault()
    source = @sourceData.val()
    
    if source is 'SDSS3SpectralData'
      params = @identifier.val()
    else
      unless @source == 'channel'
        params = @params.val()
    @tool.bindTool source, params

module.exports = DataSettings
