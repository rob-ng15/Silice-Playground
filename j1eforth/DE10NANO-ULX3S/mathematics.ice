// Hardware Accelerated Mathematics For j1eforth

// um/mod ( udl udh u -- ur uq )
// UNSIGNED 32 by 16 bit division giving remainder and quotient
// INPUT divisor from j1eforth is 16 bit expanded to 32 bit
// OUTPUT quotient and remainder are 32 bit, truncated by j1eforth

algorithm unsigneddiv(
    input   uint32  dividend,
    input   uint16  divisor,
    output  uint32  quotient,
    output  uint32  remainder,
    input   uint1   start,
    output  uint1   active
) <autorun> {
    uint32  dividend_copy = 0;
    uint32  divisor_copy = 0;
    uint5   bit = 0;
    
    while (1) {
        switch( active ) {
            case 0: {
                if( start ) {
                    if( divisor != 0 ) {
                        bit = 31;
                        quotient = 0;
                        remainder = 0;
                        dividend_copy = dividend;
                        divisor_copy = { 16b0, divisor};
                        active = 1;
                    } else {
                        quotient = 32hffff;
                        remainder = 32hffff;
                    }
                }
            }
            
            case 1: {
                if( ( ( remainder << 1 ) + dividend_copy[0,1] ) >= divisor_copy ) {
                    remainder = ( ( remainder << 1 ) + dividend_copy[0,1] ) - divisor_copy;
                    quotient[bit,1] = 1;
                } else {
                    remainder = ( ( remainder << 1 ) + dividend_copy[0,1] );
                }
                bit = bit - 1;
                active = ( bit !=0 ) ? 1 : 0;
            }
        }
    }
}
