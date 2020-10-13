( Base words implemented in assembler        JCB 13:10 08/24/10)

meta
: noop      T                       alu ;
: +         T+N                 d-1 alu ;
: xor       T^N                 d-1 alu ;
: and       T&N                 d-1 alu ;
: or        T|N                 d-1 alu ;
: invert    ~T                      alu ;
: =         N==T                d-1 alu ;
: <         N<T                 d-1 alu ;
: u<        Nu<T                d-1 alu ;
: swap      N     T->N              alu ;
: dup       T     T->N          d+1 alu ;
: drop      N                   d-1 alu ;
: over      N     T->N          d+1 alu ;
: nip       T                   d-1 alu ;
: >r        N     T->R      r+1 d-1 alu ;
: r>        rT    T->N      r-1 d+1 alu ;
: r@        rT    T->N          d+1 alu ;
: @         [T]                     alu ;
: !         T     N->[T]        d-1 alu
            N                   d-1 alu ;
: dsp       dsp   T->N          d+1 alu ;
: lshift    N<<T                d-1 alu ;
: rshift    N>>T                d-1 alu ;
: 1-        T-1                     alu ;
: 2r>       rT    T->N      r-1 d+1 alu
            rT    T->N      r-1 d+1 alu
            N     T->N              alu ;
: 2>r       N     T->N              alu
            N     T->R      r+1 d-1 alu
            N     T->R      r+1 d-1 alu ;
: 2r@       rT    T->N      r-1 d+1 alu
            rT    T->N      r-1 d+1 alu
            N     T->N          d+1 alu
            N     T->N          d+1 alu
            N     T->R      r+1 d-1 alu
            N     T->R      r+1 d-1 alu
            N     T->N              alu ;
: unloop
            T               r-1     alu
            T               r-1     alu ;
: exit      return ;

\ Elided words
: dup@      [T]   T->N          d+1 alu ;
: dup>r     T     T->R          r+1 alu ;
: 2dupxor   T^N   T->N          d+1 alu ;
: 2dup=     N==T  T->N          d+1 alu ;
: !nip      T     N->[T]        d-1 alu ;
: 2dup!     T     N->[T]            alu ;

\ Words used to implement pick
: up1       T                   d+1 alu ;
: down1     T                   d-1 alu ;
: copy      N                       alu ;

: module[ there [char] " parse preserve ;
: ]module s" Compiled " type count type space there swap - . cr ;
