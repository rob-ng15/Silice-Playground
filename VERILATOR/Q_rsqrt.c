#include <stdio.h>

float Q_rsqrt( float number )
{
	int i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = * ( long * ) &y;                       // evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
	y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

	return y;
}

int main( void ) {
    printf("SQRT  2.0 = %f\n",Q_rsqrt(  2.0 ) );
    printf("SQRT  3.0 = %f\n",Q_rsqrt(  3.0 ) );
    printf("SQRT 10.0 = %f\n",Q_rsqrt( 10.0 ) );
    printf("SQRT 25.0 = %f\n",Q_rsqrt( 10.0 ) );
    printf("SQRT 50.0 = %f\n",Q_rsqrt( 10.0 ) );
}
