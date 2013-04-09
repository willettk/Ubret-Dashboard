class DataSource extends Backbone.AssociatedModel
  manager: require 'modules/manager'
  extSubjects: require 'collections/external_subjects'
  zooSubjects: require 'collections/zooniverse_subjects'

  relations: [
    type: Backbone.Many
    key: 'params'
    relatedModel: require 'models/param'
    collectionType: require 'collections/params'
  ]

  defaults:
    params: []

  idAttribute: "tool_id"

  # DS API
  data: =>
    if @isZooniverse()
      url = @manager.get('sources_id').get('1')
        .get('search_types')[@get('search_type')].url
      new @zooSubjects([], 
        params: @get('params')
        search_type: @get('search_type')
        url: url)
    else if @isExternal()
      url = @manager.get('sources').get(@get('source_id')).get('url')
      new @extSubjects([], {params: @get('params'), url: url })
    else
      throw new Error('unknown source type')

  isExternal: =>
    (@get('source_type') is 'external')

  isZooniverse: =>
    (@get('source_id') is '1')

  isInternal: =>
    (@get('source_type') is 'internal')

module.exports = DataSource