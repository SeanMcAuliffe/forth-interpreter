require 'open3'

def interpret(input)
    stdout, stderr, status = Open3.capture3("ruby forth.rb", stdin_data: input)
    [stdout, status]
end

inputs_and_outputs = [
    ["2 4 6 8 . . . .", "8 6 4 2 ok\n"],
    ["5 DUMP 6 DUMP + DUMP 7 DUMP 8 DUMP + DUMP * DUMP . DUMP", "[5]\n[5, 6]\n[11]\n[11, 7]\n[11, 7, 8]\n[11, 15]\n[165]\n165 []\nok\n"],
    ["42 0 SWAP - .", "-42 ok\n"],
    ["48 DUP .\" The top of the stack is \" . CR .\" which looks like \'\" DUP EMIT .\" \' in ASCII\"", "The top of the stack is 48 \nwhich looks like '0' in ASCII ok\n"],
    ["3 4 < INVERT .", "0 ok\n"],
    ["3 4 + .", "7 ok\n"],
    ["5 6 + 7 8 + * .", "165 ok\n"],
    [": neg 0 SWAP - ; 5 neg .", "-5 ok\n"],
    [": fac ( n1 -- n2 ) DUP 1 > ( recursive factorial )
        IF DUP 1 - fac *
        ELSE DROP 1 THEN
        ; 5 fac .", "120 ok\n"],
    [": faci 1 SWAP 1 + 1 DO I * LOOP ; 5 faci .", "120 ok\n"],
    [": eggsize DUP 18 < IF .\" reject \" ELSE
        DUP 21 < IF .\" small \" ELSE
        DUP 24 < IF .\" medium \" ELSE
        DUP 27 < IF .\" large \" ELSE
        DUP 30 < IF .\" extra large \" ELSE
        .\" error \"
        THEN THEN THEN THEN THEN DROP ; 23 eggsize", "medium ok\n"],
]


def test_forth(input, expected_output, test_number)
    output, status = interpret(input)
  
    if output == expected_output && status.success?
      puts "Test #{test_number} passed"
    else
      puts "Test #{test_number} failed"
      puts "Expected: #{expected_output.inspect}"
      puts "Got: #{output.inspect}"
    end
end

inputs_and_outputs.each_with_index do |element, index|
    input = element[0]
    expected_output = element[1]
    test_forth(input, expected_output, index)
end
