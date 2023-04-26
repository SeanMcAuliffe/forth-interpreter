5 6 + 7 8 + * .
: neg 0 SWAP - ; ( negate the number )
5 neg .
: fac ( n1 -- n2 ) DUP 1 > ( recursive factorial )
IF DUP 1 - fac *
ELSE DROP 1 THEN
;
5 fac .
: faci 1 SWAP 1 + 1 DO I * LOOP ;
5 faci . ( iterative factorial )
: eggsize DUP 18 < IF ." reject " ELSE
DUP 21 < IF ." small " ELSE
DUP 24 < IF ." medium " ELSE
DUP 27 < IF ." large " ELSE
DUP 30 < IF ." extra large " ELSE
." error "
THEN THEN THEN THEN THEN DROP ;
23 eggsize