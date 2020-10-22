# j1eforth

## Porting to the J1+ CPU and the FOMU USB FPGA, de10nano FPGA with MiSTer I/O Board and the ULX3S FPGA

Written in Silice (https://github.com/sylefeb/Silice), using the _**WIP**_ branch.

Original J1 CPU (https://www.excamera.com/sphinx/fpga-j1.html with a very clear explanatory paper at https://www.excamera.com/files/j1.pdf).

Original j1eforth (https://github.com/samawati/j1eforth) interactive Forth environment for the J1 CPU.

## Project Motivation

I was looking for a simple design to try building for a FPGA, and came across the J1 CPU, written in Verilog, along with the j1eforth interactive Forth environment for the J1 CPU. The original j1eforth was written using a FPGA with access to 16384 x 16bit (256kbit) dual port same cycle block ram.

The FOMU has 120kbit of block ram with a single cycle latency, along with 1024kbit of single port ram (65536 x 16bit) with a dual cycle latency. The J1 CPU was recoded in Silice, adding in the cycle latencies for the block ram and the single port ram. The ROM for the CPU is copied from the block ram to the single port ram as part of the initialisation.

Silice was chosen due to my limited FPGA programming experience.

Once the design was working on the FOMU, I started the porting to the more capable DE10NANO and ULX3S boards, using their included display capabilities to provide a 640 x 480 64 colour display. Once the basic design was working, this was extended to include as many display capabilities as needed. The additions to the design were driven by the aim of creating a simple, but fully functional Forth computer.

## J1/J1+ CPU Architecture and Comparisons

The original J1 CPU had a 33 entry data stack and a 32 entry return stack. The J1+ CPU has a 257 entry data stack and a 256 entry return stack.

The original J1 CPU has this instruction encoding, providing 5 instructions:

* LITERAL
* BRANCH
* 0 BRANCH
* CALL
* ALU with 16 operations ```T N + & | ^ ~ == signed< >> -1 R [T] << DEPTH unsigned<``` with flags for returning froma call (R2P), writing to memory (N2A) and adjustments to the data and return stack pointers.

```
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+
| 1 |                    LITERAL VALUE                          |
+---------------------------------------------------------------+
| 0 | 0 | 0 |            BRANCH TARGET ADDRESS                  |
+---------------------------------------------------------------+
| 0 | 0 | 1 |            CONDITIONAL BRANCH TARGET ADDRESS      |
+---------------------------------------------------------------+
| 0 | 1 | 0 |            CALL TARGET ADDRESS                    |
+---------------------------------------------------------------+
| 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|   | RSTACK| DSTACK|
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+

T   : Top of data stack
N   : Next on data stack
PC  : Program Counter
 
LITERAL VALUES : push a value onto the data stack
CONDITIONAL    : BRANCHS pop and test the T
CALLS          : PC+1 onto the return stack

T2N : Move T to N
T2R : Move T to top of return stack
N2A : STORE T to memory location addressed by N
R2P : Move top of return stack to PC

RSTACK and DSTACK are signed values (twos compliment) that are
the stack delta (the amount to increment or decrement the stack
by for their respective stacks: return and data)
```

The J1+ CPU adds up to 16 new alu operations, encoded using ALU bit 4 to determine if a J1 or a J1+ ALU operation. The J1+ ALU instruction encoding is:

```
+---------------------------------------------------------------+
| 0 | 1 | 1 |R2P| ALU OPERATION |T2N|T2R|N2A|J1+| RSTACK| DSTACK|
+---------------------------------------------------------------+
| F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
+---------------------------------------------------------------+
```

The J1+ new ALU operations are ```==0 <>0 <> +1 *2 /2 signed> unsigned> <0 >0 abs max min negate - signed>=```

Binary ALU Operation Code | J1 CPU | J1+ CPU | J1 CPU Forth Word (notes) | J1+ CPU Forth Word | J1+ Implemented in j1eforth
:----: | :----: | :----: | :----: | :----: | :----:
0000 | T | T==0 | (top of stack) | 0= | X
0001 | N | T<>0 | (next on stack) | 0<> | X
0010 | T+N | N<>T | + | <> | X
0011 | T&N | T+1 | and | 1+ | X
0100 | T&#124;N | T<<1 | or | 2&#42; | X
0101 | T^N | T>>1 | xor | 2/ | (in CPU not j1eforth)
0110 | ~T | N>T | invert | > <br> (signed) | X
0111 | N==T | NU>T | = | > <br> (unsigned) | X
1000 | N<T | T<0 | < <br> (signed) | 0< | X
1001 | N>>T | T>0 | rshift | 0> | X
1010 | T-1 | ABST | 1- | abs | X
1011 |  rt | MXNT | (push top of return stack to data stack) | max | X
1100 | [T] | MNNT | @ <br> (read from memory) | min | X
1101 | N<<T | -T | lshift | negate | X
1110 | dsp | N-T | (depth of stacks) | - | (in CPU not j1eforth)
1111 | NU<T | N>=T | < <br> (unsigned) | >= <br> (signed) | X

*I am presently unable to add the 2/ or - to the j1eforth ROM, as the compiled ROM is no longer functional. Some assistance to add these instructions would be appreciated.*

### Memory Map - Common Peripherals

Memory mapping is used for peripheral access. These memory addresses are common across the FOMU, DE10NANO and ULX3S.

Hexadecimal Address | Usage
:----: | :----:
0000 - 7fff | Program code and data<br>The J1/J1+ CPU access 16bit memory, address rangle 0000-3fff. Memory is treated as byte accessible.
f000 | INPUT/OUTPUT (best to leave to j1eforth to operate via IN/OUT buffers).<br>FOMU and DE10NANO input/output is via UART.<br>ULX3S input/output is via UART or PS/2 keyboard (awaiting implementation).
f001 | INPUT/OUTPUT status register (bit 1 = OUTPUT buffer full, bit 0 = INPUT character available, best to leave to j1eforth to operate via IN/OUT buffers).
f002 | LED input/output bitfield `led led!` sets the LED, `led@` places the LED status onto the stack.<br>FOMU RGB led { r,g,b }<br>DE10NANO and ULX3S { led7, led6, led5, led4, led3, led2, led1, led0 }.
f003 | BUTTONS input bitfield `buttons@` places the buttons status onto the stack.<br>FOMU { button3, button2, button1, button0 }<br>DE10NANO { switch3, switch2, switch1, switch0, button1, button0 }.<br>ULX3S { button6, button5, button4, button3, button2, button1, button0 }.
f004 | TIMER 1hz (1 second) counter since boot, `timer@` places the timer onto the stack

### Forth Words to try

__j1eforth__ defaults to __hex__ for numbers. 

* `.` prints the top of the stack in the current base, `.#` does the same in decimal.
* `u.` prints the _unsigned_ top of the stack in the current base, `u.#` does the same in decimal.
* `.r` prints the second in the stack, aligned to top of stack digits, in the current base, `.r#` does the same in decimal.
* `u.r` prints the _unsigned_ second in the stack, aligned to top of stack digits, in the current base, `u.r#` does the same in decimal.

* `cold` reset
* `words` list known Forth words
* `cr` output a carriage return
* `2a emit` output a * ( character 2a (hex) 42 (decimal) ) to the terminal
* `decimal` use decimal notation
* `hex` use hexadecimal notation

The j1eforth wordlist has been extended to include some double (32 bit) integer words, including `2variable` to create a double variable, double integer arithmetic, along with some words for manipulating double integers on the stack.

* `2variable` creates a named double integer variable
* `2!` writes the double integer on the stack to a double integer variable (this was already part of j1eforth)
* `2@` reads a double integer variable to the stack (this was already part of j1eforth)
* `s>d` converts a single integer on the stack to a double integer on the stack
* `d1+` and `d1-` increment and decrement the double integer on the stack
* `d2*` and `d2/` double and halve the double integer on the stack
* `d+` and `d-` do double integer addition and subtraction
* `d=` do double integer comparison
* `dand`, `dor`, `dxor` and `dinvert` do double integer binary arithmetic
* `dnegate` change sign of the double integer on the stack (this was already part of j1eforth)
* `2swap` `2over`, `2rot` and `2nip` along with the j1eforth `2dup` and `2drop` work with double integers on the stack
* `m*` and `um*` perform single integer signed and unsigned multiplication giving a double integer result (these were already part of j1eforth)
* `m/mod` and `um/mod` divide a double integer by a single integer, signed and unsigned, to give a single integer remainder and quotient (these were already part of j1eforth)

__Copy'n'Paste__ works via the UART allowing more complicated programs to be created on a host computer and transferred to the FPGA for running. Small examples are provided in each FPGA specific directory.

__CTRL-H__ provides a BACKSPACE to allow correction of text entry errors.
