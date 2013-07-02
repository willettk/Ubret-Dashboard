class Param extends Backbone.AssociatedModel

  isValid: =>
    if @get('required')
      val = @get('val')
      console.log val if @get('key') is 'tolerance'
      if _.isUndefined(val) or val is ""
        false
      else
        validation = @get('validation')
        if _.isUndefined(validation)
          true
        else if _.isString(validation)
          true
        else if _.isFunction(validation)
          validation(val)
        else if _.isArray(validation)
          validation[0] < val and validation[1] > val
    else
      true

module.exports = Param