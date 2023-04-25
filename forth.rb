# Simple Forth Interpreter
# CSC 330, Spring 2023
# Sean McAuliffe, V00913346


#-------------------------------------------------------------------------------
class SyntaxParser
    def initialize program
        @program = program
        @tokens = []
        tokenize()
        remove_comments()
    end

    def tokenize
        # This method reads in the program and converts it into
        # a list of tokens with comments removed
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

    def tokens
        @tokens
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
    def initialize(_if, _else)
        @_if = _if
        @_else = _else
    end
    def to_s
        "ForthConditional: IF: #{@_if.map { |t| t.to_s }.join(', ')} \
         \nELSE: #{@_else.map { |t| t.to_s }.join(', ')}"
    end
    def if_tokens
        @_if
    end
    def else_tokens
        @_else
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthBeginUntil
    def initialize(_body)
        @_body = _body
    end
    def to_s
        "ForthBeginUntil: BEGIN: #{@_begin.map { |t| t.to_s }.join(', ')}"
    end
    def body_tokens
        @_body
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthWord
    def initialize word
        @word = word
    end
    def word
        @word.upcase
    end
    def to_s
        "ForthWord: #{@word}"
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthUserWord
    def initialize word
        @word = word.to_s
    end
    def to_s
        "ForthUserWord: #{@word}"
    end
    def word 
        @word.upcase
    end
end
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
class ForthValue
end

class ForthInteger < ForthValue
    def initialize value
        @value = value
    end
    def value
        @value
    end
    def value= x
        @value = x
    end
    def to_s
        "ForthInteger: #{@value.to_s}"
    end
end

class ForthString < ForthValue
    def initialize str
        @str = str
    end
    def str
        @str
    end
    def str= x
        @str = x
    end
    def to_s
        "ForthString: #{@str.to_s}"
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
        "mod" => :modulo,
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
        @syntax_tokens = tokens
        @out = Printer.new
        @stack = ForthStack.new(@out)
        @string_flag = false
        @string_buffer = "" 
        @user_word_flag = false
        @user_word_buffer = []
        @semantic_tokens = semantic_parse(@syntax_tokens)
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
        if_flag = false
        if_tokens = []
        else_flag = false
        else_tokens = []
        in_conditional = false
        sem_tok = []
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
                #@string_buffer += token[2..-1] + " " #TODO: Check length and do conditionally
                next
            elsif @string_flag 
                if token.end_with? "\"" # end of string
                    @string_flag = false
                    @string_buffer += token[0..-2]
                    sem_tok.push(ForthString.new(@string_buffer))
                    @string_buffer = ""
                    next
                end
                @string_buffer += token + " "
                next
            elsif token.upcase == "IF"
                sem_tok.push("IF")
                next
            elsif token.upcase == "ELSE"
                sem_tok.push("ELSE")
                next
            elsif token.upcase == "THEN"
                sem_tok.push("THEN")
                next
            elsif token.upcase == "BEGIN"
                sem_tok.push("BEGIN")
                next
            elsif token.upcase == "UNTIL"
                sem_tok.push("UNTIL")
                next
            elsif WORDS.has_key?(token.upcase) # built-in word
                sem_tok.push(ForthWord.new(token.upcase))
                next
            elsif token.class == ForthEOC
                sem_tok.push(ForthEOC.new) unless @user_word_flag
            elsif token.to_i.to_s == token # integer
                sem_tok.push(ForthInteger.new(token.to_i))
            elsif USER_WORDS.has_key?(token.upcase)
                sem_tok.push(ForthUserWord.new(token.upcase))
            else 
                raise "unknown token: #{token}"
            end
        end
        return sem_tok
    end

    def build_begin_until(program_tokens, i)
        body = []
        i += 1
        token = program_tokens[i]
    
        while token != "UNTIL"
            if token.class == ForthEOC # Skip internal EOCs
                i += 1
                token = program_tokens[i]
                next
            end
            if token == "BEGIN"
                j, begin_until = build_begin_until(program_tokens, i)
                i = j
                body.push(begin_until)
                i += 1
                next
            end
            body.push(token)
            i += 1
            token = program_tokens[i]
        end
    
        return i, ForthBeginUntil.new(body)
    end

    def build_conditional(program_tokens, i)
        # Given a sequence of tokens ending starting with IF
        # Find all of the tokens between IF (and possibly ELSE) and THEN
        # If either IF, or ELSE block contains another IF, then recurse
        # to build the conditional object contained in either branch
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

    def parse_conditionals(program_tokens)
        # Find all IF statements in the program
        # Build a ForthConditional object for each
        tokens = []
        i = 0
        l = program_tokens.length
        while i < l
            token = program_tokens[i]
            if token == "IF"
                j, conditional = build_conditional(program_tokens, i)
                i = j
                tokens.push(conditional)
            elsif token == "BEGIN"
                j, begin_until = build_begin_until(program_tokens, i)
                i = j
                tokens.push(begin_until)
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
            i = 0
            # program_tokens.each do |token|
            while i < count
                token = program_tokens[i]

                if token.class == ForthBeginUntil
                    loop do
                        run(token.body_tokens)
                        break if @stack.top_nonzero?
                    end
                    i += 1
                    next
                end

                # Recusrively handle ForthConditionals
                if token.class == ForthConditional
                    if @stack.top_nonzero?
                        run(token.if_tokens)
                    else
                        run(token.else_tokens)
                    end
                    i += 1
                    next
                end
                
                # Evaluate the current token as a built-in word, 
                # integer, or string or as a user-defined word
                if token.class == ForthInteger
                    @stack.push(token.value)
                elsif token.class == ForthString
                    @out._print token.str
                elsif token.class == ForthWord
                    evaluate_builtin(token.word)
                elsif token.class == ForthUserWord
                    # Parse the conditionals in the user-defined word tokens
                    # and then run the tokens
                    evaluate_userword(token.word)
                elsif token.class == ForthEOC
                    if @out.trailing_space?
                        @out._puts "ok"
                    else
                        @out._puts " ok"
                    end
                else
                    raise "unknown token: #{token}"
                end

                i += 1

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
