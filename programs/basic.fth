2 4 6 8 . . . .
5 6 + 7 8 + * .
5 DUMP 6 DUMP + DUMP 7 DUMP 8 DUMP + DUMP * DUMP . DUMP
42 0 SWAP - . (this should be ignored)
48 DUP ." The top of the stack is " . CR ." which looks like '" DUP EMIT ." ' in ASCII"
3 4 ( this too ) < INVERT . 
DUMP DROP dump 
.