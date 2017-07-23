require! {
  backbone4000: { Model }
  subscriptionman2: { Core, simpleMatcher }
  bluebird: p
  'subscriptionman2/promise': { promiseEventMixin }
}


console.log simpleMatcher
export StateMachine = Core.extend4000 simpleMatcher, promiseEventMixin, do
      
  verifyJump: (name) ->
    if not @states then return true
    if not @state then return true
    if name is 'error' then return true
    if @states[@state][name] then return true
    false
    
  setState: (name, data) ->
    if not @state then @state = @get 'state'
    if not @verifyJump(name)
      return @setState 'error', new Error "invalid jump from #{@state} to #{name} with args #{JSON.stringify(data)}"

    oldState = @state
    @set state: @state = name

    p.props do
      changeState: @eventPromise "changeState", name, data, oldState
      state: @eventPromise "state:#{name}", data, oldState
    .then ~>
      try
        @["state_#{name}"]?(data).then? (res) ~>
          switch res?@@
            | String => @setState res
            | Object => if res.state? then @setState res.state, res.data
      catch error
        @setState 'error', error
      

