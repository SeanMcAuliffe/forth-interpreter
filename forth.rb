# Simple Forth Interpreter
# CSC 330, Spring 2023
# Sean McAuliffe, V00913346

# This is a simple Forth interpreter. It reads in a file from standard input
# and executes it. The indended use is:
# ruby forth.rb < sample_program.fth

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

class ConditionalBlock
    def initialize(_if, _else)
        @_if = _if
        @_else = _else
    end
end

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

class ForthUserWord
    def initialize word
        @word = word.to_s
        #@code = token_list[1..-1]
    end
    def to_s
        "ForthUserWord: #{@word}"# #{@code.map { |x| x.to_s }} " 
    end
    def word 
        @word.upcase
    end
end

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
        @stack[-1] != 0
    end

end

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
    # Forth program indicated by the : and ; words
    USER_WORDS = {}

    def initialize(tokens)
        @syntax_tokens = tokens
        @semantic_tokens = []
        @out = Printer.new
        @stack = ForthStack.new(@out)
        @string_flag = false # are we in a string
        @string_buffer = "" 
        @in_condition_block = false # are we in an if block
        @condition = true # go ahead and execute the block
        @user_word_buffer = []
        @user_word_flag = false
        #puts @tokens
        @semantic_tokens = semantic_parse(@syntax_tokens)
        puts "Program Tokens:"
        puts @semantic_tokens
        puts
        puts "Program Output:"
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
        sem_tok = []
        syntax_tokens.each do |token|
            if token.start_with? ".\"" # start of string
                @string_flag = true
                #@string_buffer += token[2..-1] + " "
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
            elsif token == ":" # start of user-defined word
                @user_word_buffer = []
                @user_word_flag = true
                next
            elsif @user_word_flag # in user-defined word
                if token == ";" # end of user-defined word
                    @user_word_flag = false
                    new_word = ForthUserWord.new(@user_word_buffer[0].upcase)
                    USER_WORDS[new_word.word] = []
                    user_word_tokens = semantic_parse(@user_word_buffer)
                    USER_WORDS[new_word.word] = user_word_tokens[1..-1]
                    next
                end
                @user_word_buffer.push(token)
                next
            elsif token == "IF" # start of if block
                sem_tok.push("IF")
                next
            elsif token == "ELSE" # else block
                sem_tok.push("ELSE")
                next
            elsif token == "THEN" # end of if block
                sem_tok.push("THEN")
                next
            elsif WORDS.has_key?(token.upcase) # built-in word
                sem_tok.push(ForthWord.new(token.upcase))
                next
            elsif token.class == ForthEOC
                sem_tok.push(ForthEOC.new)
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

    def run(program_tokens)
        begin
            program_tokens.each do |token|
                if token.class == ForthEOC
                    if @out.trailing_space?
                        @out._puts "ok"
                    else
                        @out._puts " ok"
                    end
                elsif token.class == ForthWord
                    evaluate_builtin(token.word)
                elsif token.class == ForthInteger
                    @stack.push(token.value)
                elsif token.class == ForthString
                    print token.str
                elsif token.class == ForthUserWord
                    evaluate_userword(token.word)
                # elsif token == "IF"
                #     @in_condition_block = true
                #     @condition = @stack.top_nonzero?
                # elsif token == "THEN"
                #     @in_condition_block = false
                # elsif token == "ELSE"
                #     @condition = !@condition
                end
            end
        rescue => exception
            @out._puts "error: #{exception}"
        end
    end
end

# Create a new ForthInterpreter and run it
forth_program = ARGF.read
parser = SyntaxParser.new(forth_program)
interpreter = ForthInterpreter.new(parser.tokens)