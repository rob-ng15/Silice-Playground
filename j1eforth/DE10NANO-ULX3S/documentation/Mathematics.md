# Mathematics Accelerators

The J1+ CPU has 32 ALU operations, and deals with 16 bit integers. The accelerators add in additional ALU operations ( division ) and support for 32 bit integers via memory mapped co-processors.

## Division and Multiplication

* 32 bit by 16 bit division ( signed and unsigned ) giving 16 bit quotient and remainder
    * j1eforth words ```um/mod``` and ```m/mod``` ( hardware assisted )
* 16 bit by 16 bit division ( signed ) giving 16 bit quotient and remainder 
    * j1eforth words ```/mod```, ```mod```, ```/``` and ```mod``` ( hardware assisted )
    
* 16 bit by 16 bit multiplication ( signed and unsigned ) giving 32 bit product
    * j1eforth words ```um*``` and ```m*``` ( hardware assisted )
    
NOTE: j1eforth ```*/mod``` and ```*/``` ( use the above hardware assisted words )
    
## Memory Map for the Mathematics Accelerators

Hexadecimal<br>Address | Write | Read
:-----: | ----- | -----
ffa0 - ffa1 | operand1 | Total ( operand1 + operand2 )
ffa2 - ffa3 | operand2 | Difference ( operand1 - operand2 )
ffa4 - ffa5 | | Increment ( operand1 + 1 )
ffa6 - ffa7 | | Decrement ( operand1 - 1 )
ffa8 - ffa9 | | Double ( operand1 * 2 )
ffaa - ffab | | Half ( operand1 / 2 )
ffac - ffad | | Negation ( -operand1 )
ffae - ffaf | | Binary Invert ( ~operand1 )
ffb0 - ffb1 | | Binary Xor ( operand1 ^ operand2 )
ffb2 - ffb3 | | Binary And ( operand1 & operand2 )
ffb4 - ffb5 | | Binary Or ( operand1 | operand2 )
ffb6 - ffb7 | | Absolute ( abs( operand1 ) )
ffb8 - ffb9 | | Maximum ( max ( operand1, operand2 ) )
ffba - ffbb | | Minimum ( min ( operand1, operand2 ) )
ffbc | | Equal 0 ( operand1 == 0 )
ffbd | | Less than 0 ( operand1 < 0 )
ffbe | | Equal ( operand1 == operand2 )
ffbf | | Less than ( operand1 < operand2 )
| |
ffd0 - ffd1 | Dividend
ffd0 | | Quotient
ffd1 | | Remainder
ffd2 | Divisor
ffd3 | Start<br>(1) UNSIGNED (2) SIGNED | Active
| |
ffd4 | Dividend | Quotient ( single signed )                            ffd4
ffd5 | Divisor | Remainder ( single signed )                            ffd5
ffd6 | Start | Active ( single signed )                                 ffd6
| |
ffd7 - ffd8 | | Product                                                 ffd7 - ffd8
ffd7 | Factor 1 |                                                       ffd7
ffd8 | Factor 2 |                                                       ffd8
ffd9 | Start<br>(1) UNSIGNED (2) SIGNED | Active ( unsigned )           ffd9
| |
ffda | |
ffdb | |
ffdc | |
ffdd | |
ffde | |
ffdf | |

