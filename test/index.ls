require! {
  '../index.ls': { StateMachine }
  bluebird: p
  assert
  leshdash: { map, head }
  }

describe 'root', ->
  before ->

    @SM = StateMachine.extend4000 do
      states:
        init: { +bla, +blu }
        bla: { +blu }
        blu: { +end }
        end: true
        
      initialize: ->
        @log = []
        @subscribe 'changeState', (event, name, data) ~> 
          console.log "changestate", name, data
          @log.push {name: name, data: data}

  specify 'init', -> 
    sm = new @SM()

  specify 'setState', -> new p (resolve,reject) ~> 
    sm = new @SM()
    
    sm.subscribe 'state:init', (event, data) ->
      assert data is 3
      resolve true
      
    sm.setState 'init', 3
    
  specify 'fewJumps', -> new p (resolve,reject) ~>
    SM = @SM.extend4000 do
      initialize: ->
        @subscribeOnce 'state:blu', (event, data) ~> 
          @setState 'end'
        
      state_init: (data) -> new p (resolve,reject) ~>
        resolve state: 'bla', data: 81

      state_bla: (data) -> new p (resolve,reject) ~>
        resolve 'blu'

      state_blu: -> new p (resolve,reject) ~> 
        resolve { a: 'will_be_ignored' }

      state_end: (data) -> new p (resolve,reject) ~> 
        resolve!
        
    sm = new SM()

    sm.subscribeOnce 'state:end', ->
      console.log "LOG IS", sm.log
      assert.deepEqual sm.log, [ { name: 'init', data: 3 }, { name: 'bla', data: 81 }, { name: 'blu', data: undefined }, { name: 'end', data: undefined } ]
      resolve!
      
    sm.setState 'init', 3
    
  specify 'illegalState', -> new p (resolve,reject) ~> 
    sm = new @SM()
    
    sm.subscribeOnce 'state:init', (data) ->
      sm.setState 'invalid_state', bla: 8
      
    sm.subscribeOnce 'state:error', (data) ->
      assert.deepEqual map(sm.log, (.name)), [ 'init', 'error' ]
      assert head(sm.log).data is 3
      resolve true
      
    sm.setState 'init', 3
