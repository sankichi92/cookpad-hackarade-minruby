require "minruby"

# An implementation of the evaluator
def evaluate(exp, env)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    "#{evaluate(exp[1], env)}+#{evaluate(exp[2], env)}"
  when "-"
    "#{evaluate(exp[1], env)}-#{evaluate(exp[2], env)}"
  when "*"
    "#{evaluate(exp[1], env)}*#{evaluate(exp[2], env)}"
  when "%"
    "#{evaluate(exp[1], env)}%#{evaluate(exp[2], env)}"
  when "/"
    "#{evaluate(exp[1], env)}/#{evaluate(exp[2], env)}"
  when ">"
    evaluate(exp[1], env) > evaluate(exp[2], env)
  when "<"
    evaluate(exp[1], env) < evaluate(exp[2], env)
  when "=="
    evaluate(exp[1], env) == evaluate(exp[2], env)
# ... Implement other operators that you need


#
## Problem 2: Statements and variables
#

  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    output = ''
    exp[1..-1].each do |stmt|
      output += "#{evaluate(stmt, env)};\n"
    end
    output

# The second argument of this method, `env`, is an "environment" that
# keeps track of the values stored to variables.
# It is a Hash object whose key is a variable name and whose value is a
# value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    exp[1].to_s

  when "var_assign"
    # Variable assignment: store (or overwrite) the value to the environment
    #
    # Advice: env[???] = ???
    "#{exp[1]}=#{evaluate(exp[2], env)}"


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
    if evaluate(exp[1], env)
      evaluate(exp[2], env)
    else
      evaluate(exp[3], env)
    end

  when "while"
    # Loop.
    while evaluate(exp[1], env)
      evaluate(exp[2], env)
    end


#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = $function_definitions[exp[1]]

    if func.nil?
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        "console.log(#{evaluate(exp[2], env)})"
      when "Integer"
        Integer(evaluate(exp[2], env))
      when "fizzbuzz"
        fizzbuzz(evaluate(exp[2], env))
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
      args, body = $function_definitions[exp[1]]
      new_env = env.merge(
        args[0] => evaluate(exp[2], env)
      )
      evaluate(body, new_env)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions.
    #
    # Advice: $function_definitions[???] = ???
    $function_definitions[exp[1]] = exp[2..3]


#
## Problem 6: Arrays and Hashes
#

# You don't need advices anymore, do you?
  when "ary_new"
    exp[1..-1].map do |e|
      evaluate(e, env)
    end

  when "ary_ref"
    evaluate(exp[1], env)[evaluate(exp[2], env)]

  when "ary_assign"
    evaluate(exp[1], env)[evaluate(exp[2], env)] = evaluate(exp[3], env)

  when "hash_new"
    exp[1..-1].each_slice(2).map do |key, val|
      [evaluate(key, env), evaluate(val, env)]
    end.to_h

  else
    p("error")
    pp(exp)
    raise("unknown node: '#{exp[0]}'")
  end
end

def fizzbuzz(num)
  case
  when num % 15 == 0
    'FizzBuzz'
  when num % 3 == 0
    'Fizz'
  when num % 5 == 0
    'Buzz'
  else
    num
  end
end

$function_definitions = {}
env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
output = evaluate(minruby_parse(minruby_load()), env)
puts output
