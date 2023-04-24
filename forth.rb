# Simple Forth Interpreter
# CSC 330, Spring 2023
# Sean McAuliffe, V00913346

# This is a simple Forth interpreter. It reads in a file from standard input
# and executes it. The indended use is:
# ruby forth.rb < sample_program.fth

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
        @last_char == ' ' || @last_char == "\n"
    end
end

class UserWord
    def initialize name, code
        @name = name
        @code = code
    end
end

# class ForthValue
# end

# class ForthInteger < ForthValue
#     def initialize value
#         @value = value
#     end
#     def value
#         @value
#     end
#     def value= x
#         @value = x
#     end
# end

# class ForthString < ForthValue
#     def initialize str
#         @str = str
#     end
#     def str
#         @str
#     end
#     def str= x
#         @str = x
#     end
# end

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

    def initialize
        @out = Printer.new
        @stack = ForthStack.new(@out)
        @string_flag = false
        @comment_flag = false
    end

    def has_key?(key)
        WORDS.has_key?(key) || USER_WORDS.has_key?(key)
    end

    def evaluate(key)
        if WORDS.has_key?(key)
            @stack.send(WORDS[key])
        elsif USER_WORDS.has_key?(key)
            @stack.send(USER_WORDS[key])
        else
            raise "unknown word: #{key}"
        end
    end

    def run(program)
        lines = program.split("\n")
        lines.each do |line|
            words = line.split(" ")
            begin
                words.each do |word|
                    if has_key? word.upcase
                        evaluate(word.upcase)
                    elsif word == ".\"" 
                        @string_flag = true
                    elsif @string_flag
                        if word.end_with?("\"")
                            @string_flag = false
                            @out._print "#{word[0...-1]}"
                        else
                            @out._print "#{word} "
                        end
                    elsif word[0] == "("
                        @comment_flag = true
                    elsif @comment_flag
                        if word.end_with?(")") then @comment_flag = false end
                    else
                        @stack.push(word.to_i)
                    end
                end
            rescue => exception
                @out._puts "error: #{exception}"
            else
                if @out.trailing_space?
                    puts "ok"
                else
                    puts " ok"
                end
            end
        end
    end

end

# Create a new ForthInterpreter and run it
forth_program = ARGF.read
interpreter = ForthInterpreter.new
interpreter.run(forth_program)
