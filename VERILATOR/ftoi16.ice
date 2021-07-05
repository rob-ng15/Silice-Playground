// BITFIELD FOR FLOATING POINT NUMBER - IEEE-754 32 bit format
bitfield floatingpointnumber{
    uint1   sign,
    uint5   exponent,
    uint10  fraction
}

// COMBINE COMPONENTS INTO FLOATING POINT NUMBER
// NOTE exp from addsub multiply divide is 8 bit biased ( ie, exp + 15 )
// small numbers return 0, bit numbers return max
circuitry combinecomponents( input sign, input exp, input fraction, output f16 ) {
    if( ( exp > 30 ) || ( exp < 0 ) ) {
        f16 = ( exp < 0 ) ? 0 : { sign, 5b01111, 10h3ff };
    } else {
        f16 = { sign, exp[0,5], fraction[0,10] };
    }
}

// CLASSIFY EXPONENT AND FRACTION or EXPONENT
circuitry classEF( output E, output F, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 5h1f, ( floatingpointnumber(N).exponent ) == 5h0 };
    F = ( floatingpointnumber(N).fraction ) == 0;
}
circuitry classE( output E, input N ) {
    E = { ( floatingpointnumber(N).exponent ) == 5h1f, ( floatingpointnumber(N).exponent ) == 5h0 };
}

// REALIGN A 22BIT NUMBER SO MSB IS 1
circuitry normalise22( inout bitstream ) {
    while( ~bitstream[21,1] ) {
        bitstream = { bitstream[0,21], 1b0 };
    }
}
// EXTRACT 10 BIT FRACTION FROM LEFT ALIGNED 22 BIT FRACTION WITH ROUNDING
circuitry round22( input bitstream, output roundfraction ) {
    roundfraction = bitstream[11,10] + bitstream[10,1];
}

// ADJUST EXPONENT IF ROUNDING FORCES, using newfraction and truncated bit from oldfraction
circuitry adjustexp22( inout exponent, input nf, input of ) {
    exponent = 15 + exponent + ( ( nf == 0 ) & of[10,1] );
}

circuitry divbit( inout quo, inout rem, input top, input bottom, input x ) {
    sameas( rem ) temp = uninitialized;
    uint1   quobit = uninitialised;

    temp = ( rem << 1 ) + top[x,1];
    quobit = __unsigned(temp) >= __unsigned(bottom);
    rem = __unsigned(temp) - ( quobit ? __unsigned(bottom) : 0 );
    quo[x,1] = quobit;
}

algorithm main(output int8 leds) {

    // BIT Patterns can be obtained from http://weitz.de/ieee/
    // 1/3 = 16h3555
    // 1 = 16h3c00
    // 2 = 16h4000
    // 3 = 16h4200
    // 100 = 16h5640
    uint16  a = 16h4400;
    uint16  result = uninitialised;

    uint2   classEa = uninitialised;
    int8    exp = uninitialised;
    int17   sig = uninitialised;

    //while(1) {
        //if( start ) {
            //busy = 1;
            __display("a = %x { %b %b %b }",a,a[15,1],a[10,5],a[0,10]);
            ( classEa ) = classE( a );
            switch( classEa ) {
                case 2b00: {
                    exp = floatingpointnumber( a ).exponent - 15;
                    sig = ( exp < 11 ) ? { 5b1, a[0,10], 1b0 } >> ( 10 - exp ) : { 5b1, a[0,10], 1b0 } << ( exp - 11 );
                    result = ( exp > 15 ) ? ( a[15,1] ? 16hffff : 16h7fff ) : a[15,1] ? -( sig[1,16] + sig[0,1] ) : ( sig[1,16] + sig[0,1] );
                    __display("exp = %d, sig = %b, result = %x",exp,sig,result);
                }
                case 2b01: { result = 0; }
                default: { result = a[15,1] ? 16hffff : 16h7fff; }
            }
           //busy = 0;
        //}
    //}
}
