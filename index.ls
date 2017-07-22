require! {
  backbone4000: { Model }
}


export StateMachine = Model.extend4000 do
      
  verifyJump: (name) ->
    if not @states then return true
    if not @state then return true
    if name is 'error' then return true
    if @states[state][name] then return true
    false
    
  setState: (name, data) ->
    if not @state then @state = @get('state')
      
    if not @verifyJump(name)
      @setState 'error', new Error "invalid jump from #{@state} to #{name} with args #{JSON.stringify(data)}"
      
    @set state: @state = name
    @trigger "state_#{name}", name, data

    try
      @["state_#{name}"]?!then (res) ~>
        switch res?@@
          | String => @setState res
          | Object => if res.state? then @setState res.state, res.data
    catch error
      @setState 'error', error
    




