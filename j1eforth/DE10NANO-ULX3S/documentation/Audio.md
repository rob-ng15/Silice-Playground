# Audio Processor (ULX3S only)

Audio output is implemented for the ULX3S only at present. Audio output is via the 3.5mm jack.

* Stereo audio ( two audio processors, left and right )
* Specified notes in the range Deep C to Double High C
* Selectable waveforms
    * Square (waveform 0)
    * Sawtooth (waveform 1)
    * Triangle (waveform 2)
    * Sine (waveform 3)
    * Noise (waveform 4)
* Selectable duration in milliseconds, 1000 being 1 second

## Memory Map for the Audio Output

Hexadecimal<br>Address | Write | Read
----- | ----- | -----
ffe0 | Set the Left APU waveform |
ffe1 | Set the Left APU note | 
ffe2 | Set the Left APU duration in milliseconds
ffe3 | Start the Left APU to output the specified note | Milliseconds left on the present note
ffe4 | Set the Right APU waveform |
ffe5 | Set the Right APU note | 
ffe6 | Set the Right APU duration in milliseconds
ffe7 | Start the Right APU to output the specified note | Milliseconds left on the present note

## j1eforth Audio Processor Words

AUDIO<br>Word | Usage
----- | -----
beep! | Example ```0 19 3e8 beep!``` outputs a middle c square wave for 1 second ( 3e8 hex = 1000 milliseconds ) to left and right channels
beep? | Example ```beep?``` waits for the APU to finish (present note) on left and right channels

_```beepL!```, ```beepR!``` , ```beepL?``` and ```beepR?``` are for the respective single channels only_

## Note table (HEX)

Octave | C | C#/Db | D | D#/Eb | E | F | F#/Gb | G | G#/Ab | A | A#/Bb | B
:--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--:
C2 (Deep C) | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | a | b | c
C3 | d | e | f | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18
C4 (Middle C) | 19 | 1a | 1b | 1c | 1d | 1e | 1f | 20 | 21 | 22 | 23 | 24
C5 (Tenor C) | 25 | 26 | 27 | 28 | 29 | 2a | 2b | 2c | 2d | 2e | 2f | 30
C6 (Soprano C) | 31 | 32 | 33 | 34 | 35 | 36 | 37 | 38 | 39 | 3a | 3b | 3c
C7 (Double High C) | 3d
