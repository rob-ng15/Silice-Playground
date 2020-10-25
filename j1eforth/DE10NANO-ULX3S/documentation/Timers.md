# Timers and Random Number Generator

* Two 1hz (1 second) counters
    * A systemclock, number of seconds since startup
    * A user resetable timer
    
* Two 1khz (1 millisecond) countdown timers
    * A sleep timer
    * A user resetable timer

* An LFSR 16 bit pseudo random number generator
    
## Memory Map for the Timers and RNG

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
f004 | | Read the 1hz systemClock
ffe8 | Reset the 16 bit pseudo random number generator | Read a 16 bit pseudo random number
ffed | Reset the 1hz user timer | Read the 1hz user timer
ffee | Start the 1khz user timer | Read the 1khz user timer
ffef | Start the 1khz sleep timer | Read the 1khz sleep timer

## j1eforth Timers and RNG words

TIMER and RNG<br>Word | Usage
----- | -----
clock@ | Example ```clock@``` puts the systemClock, number of seconds since startup onto the stack
timer1hz! | Example ```timer1hz!``` resets the 1hz user timer
timer1hz@ | Example ```timer1hz@``` puts the 1hz user timer onto the stack
timer1khz! | Example ```3e8 timer1khz!``` starts the 1khz timer at 1 second ( 3e8 hex = 1000 milliseconds )
timer1khz? | Example ```timer1khz?``` waits for the 1khz timer to finish
sleep | Example ```3e8 sleep``` waits for 1 second ( 3e8 hex = 1000 milliseconds )
rng | Example ```10 rng``` puts a pseudo random number from 0 - f (hex 10 - 1) onto the stack
