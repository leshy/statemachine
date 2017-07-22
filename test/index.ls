require! { '../index.ls': { StateMachine } }

describe 'root', ->
  specify 'init', ->

    Defined = StateMachine.extend4000 do
      states:
        init: { +bla, +blu }
        bla: { +blu }
        blu: { +end }
        end: true
        
    console.log StateMachine
    stateMachine = new StateMachine()
