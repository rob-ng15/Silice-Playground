#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

float pawslnf( float x ) {
    float series = radians, power = radians, square = radians * radians, factorial = 1;
    int factorialcount = 1, flipflop = 1;
    for( int n = 1; n < 16; n++ ) {
        power = power * square;
        factorial = factorial * ( ++factorialcount ) * ( ++factorialcount );
        switch( flipflop ) {
            case 1: series = series - ( power / factorial );
                break;
            case 0: series = series + ( power / factorial );
                break;
        }
        flipflop = 1 - flipflop;
    }
    return( series );
}

float pawspowf(float x, float y) {
   float result = x;
   int Y = (int)y;
   while(Y > 2) {
      Y /= 2; result *= result;
      if(result < 1e-100 || result > 1e100) {
	 return result;
      }
   }
   while(Y > 1) {
      Y--; result *= x;
      if(result < 1e-100 || result > 1e100) {
	 return result;
      }
   }
   return result;
}

int main( void ) {

    INITIALISEMEMORY();

    // set up curses library
    initscr();
    start_color();

    clear();
    move( 0, 0 );
    attron( 7 );

    printw( "Power Tests:\n\n" );
    for( int i = -360; i < 360; i += 30 ) {
        float angle = i *0.01745329252;
        printw("deg =  %d qsinf = %f, qcosf = %f, qtanf = %f\n", i, pawssinf( angle ), pawscosf( angle ), pawstanf( angle ) );
        refresh();
    }

    while(1) {}
}
