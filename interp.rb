require "minruby"

# An implementation of the evaluator
def evaluate(exp, env, function_definitions)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env, function_definitions) + evaluate(exp[2], env, function_definitions)
  when "-"
    evaluate(exp[1], env, function_definitions) - evaluate(exp[2], env, function_definitions)
  when "*"
    evaluate(exp[1], env, function_definitions) * evaluate(exp[2], env, function_definitions)
  when "%"
    evaluate(exp[1], env, function_definitions) % evaluate(exp[2], env, function_definitions)
  when "/"
    evaluate(exp[1], env, function_definitions) / evaluate(exp[2], env, function_definitions)
  when ">"
    evaluate(exp[1], env, function_definitions) > evaluate(exp[2], env, function_definitions)
  when "<"
    evaluate(exp[1], env, function_definitions) < evaluate(exp[2], env, function_definitions)
  when "=="
    evaluate(exp[1], env, function_definitions) == evaluate(exp[2], env, function_definitions)
  # ... Implement other operators that you need

  
#
## Problem 2: Statements and variables
#

  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    i = 1
    last = nil
    while exp[i]
      last = evaluate(exp[i], env, function_definitions)
      i = i + 1
    end
    last

  # The second argument of this method, `env`, is an "environment" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    env[exp[1]]

  when "var_assign"
    # Variable assignment: store (or overwrite) the value to the environment
    #
    # Advice: env[???] = ???
    env[exp[1]] = evaluate(exp[2], env, function_definitions)


#
## Problem 3: Branchs and loops
#

  when "if"
    # Branch.  It evaluates either exp[2] or exp[3] depending upon the
    # evaluation result of exp[1],
    #
    # Advice:
    #   if ???
    #     ???
    #   else
    #     ???
    #   end
    if evaluate(exp[1], env, function_definitions)
      evaluate(exp[2], env, function_definitions)
    else
      evaluate(exp[3], env, function_definitions)
    end

  when "while"
    # Loop.
    while evaluate(exp[1], env, function_definitions)
      evaluate(exp[2], env, function_definitions)
    end


#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = function_definitions[exp[1]]

    if func == nil
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env, function_definitions))
      when "Integer"
        Integer(evaluate(exp[2], env, function_definitions))
      when "fizzbuzz"
        fizzbuzz(evaluate(exp[2], env, function_definitions))
      when "require"
        require(evaluate(exp[2], env, function_definitions))
      when "minruby_parse"
        minruby_parse(evaluate(exp[2], env, function_definitions))
      when "minruby_load"
        minruby_load()
      else
        raise("unknown builtin function: '#{exp[1]}'")
      end
    else


#
## Problem 5: Function definition
#

      # (You may want to implement "func_def" first.)
      #
      # Here, we could find a user-defined function definition.
      # The variable `func` should be a value that was stored at "func_def":
      # a parameter list and an AST of function body.
      #
      # A function call evaluates the AST of function body within a new scope.
      # You know, you cannot access a variable out of function.
      # Therefore, you need to create a new environment, and evaluate the
      # function body under the environment.
      #
      # Note, you can access formal parameters (*1) in function body.
      # So, the new environment must be initialized with each parameter.
      #
      # (*1) formal parameter: a variable as found in the function definition.
      # For example, `a`, `b`, and `c` are the formal parameters of
      # `def foo(a, b, c)`.
      args = function_definitions[exp[1]][0]
      body = function_definitions[exp[1]][1]

      new_env = {}
      i = 0
      while exp[i]
        new_env[exp[i][0]] = exp[i][1]
        i = i + 1
      end

      i = 0
      while args[i]
        new_env[args[i]] = evaluate(exp[i + 2], env, function_definitions)
        i = i + 1
      end

      evaluate(body, new_env, function_definitions)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into function_definitions.
    #
    # Advice: function_definitions[???] = ???
    function_definitions[exp[1]] = [exp[2], exp[3]]


#
## Problem 6: Arrays and Hashes
#

  # You don't need advices anymore, do you?
  when "ary_new"
    arr = []
    i = 1
    while exp[i]
      arr[i - 1] = evaluate(exp[i], env, function_definitions)
      i = i + 1
    end
    arr

  when "ary_ref"
    evaluate(exp[1], env, function_definitions)[evaluate(exp[2], env, function_definitions)]

  when "ary_assign"
    evaluate(exp[1], env, function_definitions)[evaluate(exp[2], env, function_definitions)] = evaluate(exp[3], env, function_definitions)

  when "hash_new"
    hash = {}
    i = 1
    while exp[i]
      hash[evaluate(exp[i], env, function_definitions)] = evaluate(exp[i + 1], env, function_definitions)
      i = i + 2
    end
    hash

  else
    p("error")
    pp(exp)
    raise("unknown node: '#{exp[0]}'")
  end
end

def fizzbuzz(num)
  if num % 15 == 0
    'FizzBuzz'
  elsif num % 3 == 0
    'Fizz'
  elsif num % 5 == 0
    'Buzz'
  else
    num
  end
end

function_definitions = {}
env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
evaluate(minruby_parse(minruby_load()), env, function_definitions)
