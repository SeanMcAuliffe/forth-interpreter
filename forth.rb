# Simple Forth Interpreter
# CSC 330, Spring 2023
# Sean McAuliffe, V00913346

# This is a simple interpreter for a subset of the Forth programming language.
# The intended use is to run the program from the command line, piping a Forth
# program file (.fth) into the interpreter. For example:
# ruby forth.rb < test.fth

# The Forth program file should contain nothing other than valid Forth words
# integers, strings, control structures, and comments.

# There is no interactive REPL-like behaviour implemented, i.e. simply running
# the interpreter without a program file will not allow the user to enter
# Forth commands directly (see README for usage instructions).

# The interpreter will print the output of the program to the console, for each
# "line" of input (multiline control structures will be treated as one line)
# the interpreter will evaluate, print the output, followed by an "ok" token.

# The interpreter will also print any errors to the console if they occur
# during the execution of the program. Some errors will not lead to program
# termination, and will only effect the current line of execution.

# The interpreter is implemented across the following classes:
#   - ForthInterpreter
#   - ForthStack
#   - SyntaxParser
#   - ForthEOC

# The following classes are utilities
#   - Printer

# The following classes are used to represent Forth values and control structures
#   - ForthConditional
#   - ForthBeginUntil
#   - ForthDoLoop
#   - ForthWord
#   - ForthUserWord
#   - ForthInteger
#   - ForthString

# The hash of builtin words is stored immutably inside the interpreter
# which also contains a mutable hash of user defined words.

# The interpreter does several passes of pre-processing / parsing before
# executing the program. The first pass (Syntactic Parsing) is to tokenize
# the program, removing # comments and splitting the program into a list of
# tokens. The second pass (semantic parsing) is to parse the tokens into
# Forth control structures and values. The third pass is to identify condotional
# and loop structures and create objects to later orchestrate their execution
# when encountered by the final pass: execution.

# Execution is done by iterating over the list of tokens, and executing each
# token in turn. Each token either modifies the stack directly (builtins),
# or recursively invokes a list of tokens which can modify the execution
# (ifelse, loops, etc.), ultimately, all control-structure tokens evaluate
# to builtins which are executed on the stack.

# The following Forth features have been implemented
#   - Stack manipulation via builtin words
#   - Integer and string literals
#   - User defined words
#   - Recursive user defined words
#   - Recursive (nested) control structures
#       - IF ELSE THEN
#       - BEGIN UNTIL
#       - DO LOOP
#   - Comments
#   - Heap Variables

# The following Forth features have not been implemented
#   - Constants
#   - Memory allocation via ALLOT


#-------------------------------------------------------------------------------
class SyntaxParser
    attr_reader :tokens

    def initialize program
        @program = program
        @tokens = []
        tokenize()
        remove_comments()
    end

    def tokenize
        lines = @program.split("\n")
        lines.each do |line|
            tokens = line.split(" ")
            tokens.each do |token|
                @tokens.push(token) 
            end
            @tokens.push(ForthEOC.new)
        end
    end

    def remove_comments
        comment_flag = false
        token_list = @tokens
        @tokens = []
        token_list.each do |token|
            if token.start_with? "("
                comment_flag = true
            end
            @tokens.push(token) unless comment_flag
            if token.end_with? ")"
                comment_flag = false
            end
        end
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthEOC
    # End of command token
    def initialize
    end
    def to_s
        "EOC"
    end
    def upcase
        "EOC"
    end
    def start_with? x
        false
    end 
    def end_with? x
        false
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class Printer
    # This class helps format the expected 'ok' token correctly,
    # as seen in the assignment specification example output.
    def initialize
        @last_char = nil
    end

    def _print x
        @last_char = x[-1]
        print x
    end

    def _puts x
        @last_char = "\n"
        puts x
    end

    def trailing_space?
        @last_char == ' ' || @last_char == "\n" || @last_char == nil
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthConditional
    attr_reader :if_tokens
    attr_reader :else_tokens

    def initialize(_if, _else)
        @if_tokens = _if
        @else_tokens = _else
    end

    def to_s
        "ForthConditional: IF: #{@if_tokens.map { |t| t.to_s }.join(', ')} \
         \nELSE: #{@else_tokens.map { |t| t.to_s }.join(', ')}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthBeginUntil
    attr_reader :body_tokens
    def initialize(_body)
        @body_tokens = _body
    end
    def to_s
        "ForthBeginUntil: BEGIN: #{@body_tokens.map { |t| t.to_s }.join(', ')}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthDoLoop
    attr_accessor :begin
    attr_accessor :end
    attr_accessor :index
    attr_reader :body_tokens

    def initialize(_body)
        @body_tokens = _body
        @index = 0
        @begin = nil
        @end = nil
    end
    def to_s
        "ForthDoLoop: #{@body_tokens.map { |t| t.to_s }}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthWord
    attr_reader :word
    def initialize word
        @word = word.to_s.upcase
    end
    def to_s
        "ForthWord: #{word}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthUserWord < ForthWord
    def initialize word
        super word
    end
    def to_s
        "ForthUserWord: #{word}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthValue
    attr_reader :value
    def initialize x
        @value = x
    end
end

class ForthInteger < ForthValue
    def initialize value
        super value
    end
    def to_s
        "ForthInteger: #{value.to_s}"
    end
end

class ForthString < ForthValue
    def initialize str
        @value = str
    end
    def to_s
        "ForthString: #{value.to_s}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthStack
    
    def initialize(out)
        @out = out
        @stack = []
    end
    
    def push(value)
        @stack.push(value)
    end

    def add
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 + n2)
    end

    def subtract
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 - n2)
    end

    def multiply
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 * n2)
    end

    def divide
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 / n2)
    end

    def modulo
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 % n2)
    end

    def pop_print
        if @stack.empty? then raise "empty stack" end
        @out._print "#{@stack.pop} "
    end

    def duplicate
        n1 = @stack.pop
        @stack.push(n1)
        @stack.push(n1)
    end

    def swap
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n2)
        @stack.push(n1)
    end

    def drop
        @stack.pop
    end

    def dump
        @out._print '['
        @out._print @stack.join ', '
        @out._puts ']'
    end

    def over
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1)
        @stack.push(n2)
        @stack.push(n1)
    end

    def rotate
        n3 = @stack.pop
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n2)
        @stack.push(n3)
        @stack.push(n1)
    end

    def emit
        n1 = @stack.pop
        @out._print n1.chr
    end

    def carriage_return
        @out._puts ""
    end

    def equal
        n2 = @stack.pop
        n1 = @stack.pop
        if n1 == n2
            @stack.push(-1)
        else
            @stack.push(0)
        end
    end

    def greater_than
        n2 = @stack.pop
        n1 = @stack.pop
        if n1 > n2
            @stack.push(-1)
        else
            @stack.push(0)
        end
    end

    def less_than
        n2 = @stack.pop
        n1 = @stack.pop
        if n1 < n2
            @stack.push(-1)
        else
            @stack.push(0)
        end
    end

    def and
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 & n2)
    end

    def or
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 | n2)
    end

    def xor
        n2 = @stack.pop
        n1 = @stack.pop
        @stack.push(n1 ^ n2)
    end

    def invert
        n1 = @stack.pop
        @stack.push(~n1)
    end

    def top_nonzero?
        if @stack.length == 0
            false
        else
            @stack.pop != 0
        end
    end

    def pop
        @stack.pop
    end

    def push x
        @stack.push x
    end

end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# class ForthVariable
#     attr_reader :name
#     attr_accessor :value
#     attr_accessor :address
#     def initialize (name)
#         @name = name
#         @value = nil
#         @address = nil
#     end
# end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthHeap
    def initialize
        @address = 1000
        @heap = {}
    end
    def add varname
        @heap[varname.upcase] = [0, @address]
        @address += 1
    end
    def update_value varname, value
        @heap[varname.upcase][0] = value
    end
    def get_value varname
        @heap[varname.upcase][0]
    end
    def exists varname
        if varname.class != String
            false
        else
            @heap.has_key? varname.upcase
        end
    end
    def address_of_var varname
        @heap[varname.upcase][1]
    end
    def var_at_address(address)
        @heap.each do |key, value|
            if value[1] == address
                return key
            end
        end
        return nil
    end
    def dump
        @heap.each do |key, value|
            puts "#{key} => #{value}"
        end
    end
end  
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthInterpreter

    # Immutable hash of built-in words.
    WORDS = {
        "+" => :add,
        "-" => :subtract,
        "*" => :multiply,
        "/" => :divide,
        "MOD" => :modulo,
        "." => :pop_print,
        "DUP" => :duplicate,
        "SWAP" => :swap,
        "DROP" => :drop,
        "DUMP" => :dump,
        "OVER" => :over,
        "ROT" => :rotate,
        "EMIT" => :emit,
        "CR" => :carriage_return,
        "=" => :equal,
        ">" => :greater_than,
        "<" => :less_than,
        "AND" => :and,
        "OR" => :or,
        "XOR" => :xor,
        "INVERT" => :invert,
    }.freeze

    # Hash of user-defined words. Defined in the
    # Forth program indicated by : and ; 
    USER_WORDS = {}

    def initialize(tokens)
        @out = Printer.new
        @stack = ForthStack.new(@out)
        @heap = ForthHeap.new
        @operating_var = nil
        @string_flag = false
        @string_buffer = "" 
        @user_word_flag = false
        @user_word_buffer = []
        @current_do_loop = []
        @semantic_tokens = semantic_parse(tokens)
        @semantic_tokens = parse_conditionals(@semantic_tokens)
        run(@semantic_tokens)
    end

    # Sends a built-in message to the stack to modify it
    def evaluate_builtin(key)
        if WORDS.has_key?(key)
            @stack.send(WORDS[key])
        else
            raise "unknown word: #{key}"
        end
    end

    # Evaluates a user-defined word, sending 
    # the appropriate messages to the stack
    def evaluate_userword(key)
        if USER_WORDS.has_key?(key)
            tokens = USER_WORDS[key]
            run(tokens)
        else
            raise "unknown user word: #{key}"
        end
    end

    # Recursive Semantic Parser
    # Transform Tokens -> Forth values and control structures
    def semantic_parse(syntax_tokens)
        semantic_tokens = []

        syntax_tokens.each do |token|

            if token == ":" # start of user-defined word
                @user_word_buffer = []
                @user_word_flag = true
                next

            elsif @user_word_flag # in user-defined word
                if token == ";" # end of user-defined word
                    @user_word_flag = false
                    new_word = ForthUserWord.new(@user_word_buffer[0].upcase)
                    USER_WORDS[new_word.word] = []
                    # Parse the tokens of the user-defined word
                    user_word_tokens = semantic_parse(@user_word_buffer)
                    user_word_tokens = parse_conditionals(user_word_tokens)
                    user_word_tokens = user_word_tokens.reject {|t| t.class == ForthEOC}
                    USER_WORDS[new_word.word] = user_word_tokens[1..-1]
                    next
                end
                @user_word_buffer.push(token)
                next

            elsif token.start_with? ".\"" # start of string
                @string_flag = true
                next

            elsif @string_flag # in string
                if token.end_with? "\"" # end of string
                    @string_flag = false
                    @string_buffer += token[0..-2]
                    semantic_tokens.push(ForthString.new(@string_buffer))
                    @string_buffer = ""
                    next
                end
                @string_buffer += token + " "
                next

            # Start of Control Structure Indicators
            elsif token.upcase == "IF"
                semantic_tokens.push("IF")
                next
            elsif token.upcase == "ELSE"
                semantic_tokens.push("ELSE")
                next
            elsif token.upcase == "THEN"
                semantic_tokens.push("THEN")
                next
            elsif token.upcase == "BEGIN"
                semantic_tokens.push("BEGIN")
                next
            elsif token.upcase == "UNTIL"
                semantic_tokens.push("UNTIL")
                next
            elsif token.upcase == "DO"
                semantic_tokens.push("DO")
                next
            elsif token.upcase == "LOOP"
                semantic_tokens.push("LOOP")
                next
            elsif token.upcase == "I"
                semantic_tokens.push("I")
                next

            # Variables
            elsif token == "VARIABLE"
                # Grab the next token as the variable name
                variable_name = syntax_tokens[syntax_tokens.index(token) + 1]
                # Delete the next token
                syntax_tokens.delete_at(syntax_tokens.index(token) + 1)
                # Add the variable to the heap
                @heap.add(variable_name.upcase)
                next
            elsif @heap.exists token
                semantic_tokens.push(token.upcase)
                next
            elsif token == "!"
                semantic_tokens.push("!")
                next
            elsif token == "@"
                semantic_tokens.push("@")
                next 

            # Words / Values
            elsif WORDS.has_key?(token.upcase) # built-in word
                semantic_tokens.push(ForthWord.new(token.upcase))
                next
            elsif USER_WORDS.has_key?(token.upcase)
                semantic_tokens.push(ForthUserWord.new(token.upcase))
                next
            elsif token.class == ForthEOC
                semantic_tokens.push(ForthEOC.new) unless @user_word_flag
            elsif token.to_i.to_s == token # integer
                semantic_tokens.push(ForthInteger.new(token.to_i))
            else 
                raise "unknown token: #{token}"
            end

        end
        return semantic_tokens
    end

    # Recusrively construct loop structues 
    # wherever their indicators are found
    def build_loops(program_tokens, i)
        body = []
        token = program_tokens[i]
        if token == "BEGIN"
            i += 1
            token = program_tokens[i]
            while token != "UNTIL"
                if token.class == ForthEOC # Skip internal EOCs
                    i += 1
                    token = program_tokens[i]
                    next
                end
                if token == "BEGIN"
                    j, begin_until = build_loops(program_tokens, i)
                    i = j
                    body.push(begin_until)
                    i += 1
                    next
                elsif token == "DO"
                    j, do_loop = build_loops(program_tokens, i)
                    i = j
                    body.push(do_loop)
                    i += 1
                    next
                end
                body.push(token)
                i += 1
                token = program_tokens[i]
            end
        
            return i, ForthBeginUntil.new(body)
        
        elsif token == "DO"
            i += 1
            token = program_tokens[i]
            while token != "LOOP"
                if token.class == ForthEOC # Skip internal EOCs
                    i += 1
                    token = program_tokens[i]
                    next
                end
                if token == "DO"
                    j, begin_until = build_loops(program_tokens, i)
                    i = j
                    body.push(begin_until)
                    i += 1
                    next
                elsif token == "BEGIN"
                    j, do_loop = build_loops(program_tokens, i)
                    i = j
                    body.push(do_loop)
                    i += 1
                    next
                end
                body.push(token)
                i += 1
                token = program_tokens[i]
            end

            return i, ForthDoLoop.new(body)

        end
    end

    # Given a sequence of tokens ending starting with IF
    # Find all of the tokens between IF (and possibly ELSE) and THEN
    # If either IF, or ELSE block contains another IF, then recurse
    # to build the conditional object contained in either branch
    def build_conditional(program_tokens, i)
        _if = []
        _else = []
        i += 1
        token = program_tokens[i]

        # Build the IF block
        while token != "THEN" && token != "ELSE"
            if token.class == ForthEOC # Skip internal EOCs
                i += 1
                token = program_tokens[i]
                next
            end
            if token == "IF"
                j, conditional = build_conditional(program_tokens, i)
                i = j
                _if.push(conditional)
                i += 1
                next
            end
            _if.push(token)
            i += 1
            token = program_tokens[i]
        end

        # Build the ELSE block
        if token == "ELSE"
            i += 1
            token = program_tokens[i]
            while token != "THEN"
                if token.class == ForthEOC # Skip internal EOCs
                    i += 1
                    token = program_tokens[i]
                    next
                end
                if token == "IF"
                    j, conditional = build_conditional(program_tokens, i)
                    i = j
                    _else.push(conditional)
                else
                    _else.push(token)
                end
                i += 1
                token = program_tokens[i]
            end
        end

        return i, ForthConditional.new(_if, _else)
    end

    # Find all IF statements in the program
    # Build a ForthConditional object for each
    def parse_conditionals(program_tokens)
        tokens = []
        i = 0
        l = program_tokens.length
        while i < l
            token = program_tokens[i]
            if token == "IF"
                j, conditional = build_conditional(program_tokens, i)
                i = j
                tokens.push(conditional)
            elsif token == "BEGIN" || token == "DO"
                j, loop_obj = build_loops(program_tokens, i)
                i = j
                tokens.push(loop_obj)
            else
                tokens.push(token)
            end
            i += 1
        end
        return tokens
    end

    def run(program_tokens)
        begin
            count = program_tokens.length
            program_tokens.each do |token|

                # BEGIN ... UNTIL loop
                if token.class == ForthBeginUntil
                    loop do
                        run(token.body_tokens)
                        break if @stack.top_nonzero?
                    end
                    next
                end

                # DO ... LOOP loop
                if token.class == ForthDoLoop
                    loop_begin = @stack.pop
                    loop_end = @stack.pop
                    token.begin = loop_begin
                    token.end = loop_end
                    token.index = loop_begin
                    @current_do_loop.push(token)
                    loop do
                        run(token.body_tokens)
                        @current_do_loop.last.index += 1
                        break if @current_do_loop.last.index == loop_end
                    end
                    @current_do_loop.pop
                    next
                end

                # IF (ELSE) THEN block
                if token.class == ForthConditional
                    if @stack.top_nonzero?
                        run(token.if_tokens)
                    else
                        # ELSE tokens might just be []
                        # then this call has no effect
                        run(token.else_tokens)
                    end
                    next
                end

                # Variables
                if @heap.exists token
                    @operating_var = token
                    next
                end

                if token == "!"
                    @heap.update_value(@operating_var, @stack.pop)
                    @operating_var = nil
                    next
                end

                if token == "@"
                    @stack.push(@heap.get_value(@operating_var))
                    @operating_var = nil
                    next
                end
                
                # Evaluate the current token as a built-in word, 
                # integer, string, or as a user-defined word
                if token.class == ForthInteger
                    @stack.push(token.value)
                elsif token.class == ForthString
                    @out._print token.value
                elsif token.class == ForthWord
                    evaluate_builtin(token.word)
                elsif token.class == ForthUserWord
                    evaluate_userword(token.word)
                elsif token == "I"
                    @stack.push(@current_do_loop.last.index)
                elsif token.class == ForthEOC
                    if @out.trailing_space?
                        @out._puts "ok"
                    else
                        @out._puts " ok"
                    end
                else
                    raise "unknown token: #{token}"
                end

            end
        rescue => exception
            @out._puts "error: #{exception}"
        end
    end
end
#-------------------------------------------------------------------------------

forth_program = ARGF.read
parser = SyntaxParser.new(forth_program)
interpreter = ForthInterpreter.new(parser.tokens)
