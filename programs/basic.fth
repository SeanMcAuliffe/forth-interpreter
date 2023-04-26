2 4 6 8 . . . . ( comments are enclosed within parens. Example input is indented. )
5 6 + 7 8 + * . ( simple calculation )
5 DUMP 6 DUMP + DUMP 7 DUMP 8 DUMP + DUMP * DUMP . DUMP
42 0 SWAP - .
48 DUP ." The top of the stack is " . CR ." which looks like '" DUP EMIT ." ' in ASCII"
3 4 < INVERT .
DUMP DROP dump ( yes, words are case-insensitive )
. ( will cause empty stack error )