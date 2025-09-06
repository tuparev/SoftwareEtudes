let env = AbstractMessageInterpretingEnvironment()
let interpreter = AbstractMessageInterpreter(environment: env)
root.dispatcherDelegate = interpreter
