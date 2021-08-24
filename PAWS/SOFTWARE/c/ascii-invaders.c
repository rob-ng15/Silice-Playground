#include "PAWSlibrary.h"
#include <stdlib.h>
#include <stdio.h>

struct Bomb {
    int x;
    int y;
    int anim;
    struct Bomb *next;
};

/* To make this compile under Darwin/BSD I have to comment these, until
   I figure out how to fix this problem (may involve not using apple's curses
   implementation). */
#define USE_COLORS 1
#define USE_KEYS 1

//#define BULLET_PROOF 1  // debug

#define BOMB_ANIM_SIZE 4 // "frames" in bomb anim

#define FPS 5          // frames per second
#define PAINT_WAIT 4   // how many frames between row repaints

#define ALIEN30 3
#define ALIEN20 2
#define ALIEN10 1
#define ALIEN_EMPTY 0
#define ALIEN_EXPLODE1 -1
#define ALIEN_EXPLODE2 -2

#define ALIEN_WIDTH 6
#define ALIEN_HEIGHT 3
#define GUNNER_WIDTH 7
#define GUNNER_HEIGHT 2
#define SHELTER_WIDTH 7
#define SHELTER_HEIGHT 3
#define MA_HEIGHT 2
#define MA_WIDTH 6

#define GUNNER_ENTRANCE 4 // how many frames before gunner appears
#define MA_ENTRANCE 400 // how many frames before MA comes on the screen

#define STATE_INTRO 1
#define STATE_PLAY 2
#define STATE_EXPLODE 3
#define STATE_WAIT 4
#define STATE_GAMEOVER 5

const char *alienBlank =  "      ";
const char *alien30[] = { " {@@} ",
                          " /\"\"\\ ",
                          "      ",
                          " {@@} ",
                          "  \\/  ",
                          "      " };

const char *alien20[] = { " dOOb ",
                          " ^/\\^ ",
                          "      ",
                          " dOOb ",
                          " ~||~ ",
                          "      " };

const char *alien10[] = { " /MM\\ ",
                          " |~~| ",
                          "      ",
                          " /MM\\ ",
                          " \\~~/ ",
                          "      " };

const char *alienMa[] = { "_/MM\\_",
                          "qWAAWp" };

const char *gunner[]  = { "  mAm  ",
                          " MAZAM " };

const char *gunnerExplode[]  = {
                          " ,' %  ",
                          " ;&+,! ",
                          " -,+$! ",
                          " +  ^~ " };

const char *alienExplode[] = {
                         " \\||/ ",
                         " /||\\ ",
                         "      " };

const char *shelter[] = {
                         "/MMMMM\\",
                         "MMMMMMM",
                         "MMM MMM" };

const char *bombAnim =   "\\|/-";

// We have to use global variables becase our main loop is driven by
// an alarm signal - so we put them into tidy structures.
// TODO!  Define the structs, but declare the game state objects on
// the stack of main.  Down with globalisation!

struct {
    int score;
    int lives;
    int state;
    int screenCols;         // screen columns
    int screenRows;         // screen rows
    int timer;              // timer used to switch between game states
    //struct itimerval myTimer;   // alarm signal timer
} game;

struct {
    int rows, cols;         // how many rows and columns of aliens are there?
    int x, y;               // alien position
    int *table;             // the table of aliens
    // which rows and columns have been cleared?
    int emptyLeft, emptyRight, emptyTop, emptyBottom;
    int direction;
    int paintRow;           // cursor for repainting row by row
    int paintWait;          // counter for repainting row by row
    int sideAnim;           // staggered sideways movement
    int count;              // how many aliens are left?
    int anim;               // used for wiggling
    struct Bomb *headBomb;  // linked list of bombs
} aliens;

struct {
    int x;                  // x position
    int move;               // buffered moves
    int explodeTimer;       // timer used when gunner explodes
    struct {
        int x;              // x position
        int y;              // y position
    } missile;
    char *shields;          // pointer to shield table
} gun;

struct {
    int x;                  // x position
    int pointsTimer;        // how long to leave the points on the screen
} ma;


void paintShelters();
void resetAliens();
void resetShields();
void initGame();
void cleanUp(int signal);
void handleTimer(int signal);
void paintAlienRow(int row, int clean);
void paintGunner();
void paintIntro();
void paintExplodingAlien(int y, int x);
void removeAlien(int y, int x);
void paintScore();
void trimAliens();
void addBomb(int x, int y);
int removeBomb(struct Bomb *b);
void freeBombs();
void moveAliensDown();

int main( void ) {
    INITIALISEMEMORY();
    // CLEAR and SET THE BACKGROUND
    gpu_cs();
    set_background( GREY2, DKBLUE - 1, BKG_SNOW );

    // set up curses library
    initscr();
    curs_set(0); // hide cursor
    cbreak();
    noecho();
    noscroll();
#ifdef USE_KEYS
    //keypad(stdscr, TRUE);
#endif
#ifdef USE_COLORS
    if (has_colors()) {
        start_color();
        init_pair(0, COLOR_BLACK, TRANSPARENT);
        init_pair(1, COLOR_GREEN, TRANSPARENT);
        init_pair(2, COLOR_RED, TRANSPARENT);
        init_pair(3, COLOR_CYAN, TRANSPARENT);
        init_pair(4, COLOR_WHITE, TRANSPARENT);
        init_pair(5, COLOR_MAGENTA, TRANSPARENT);
        init_pair(6, COLOR_BLUE, TRANSPARENT);
        init_pair(7, COLOR_YELLOW, TRANSPARENT);
    }
#endif
    game.screenCols = COLS;

    initGame();
    paintIntro();
    game.state = STATE_INTRO;

    // TODO!
    // Instead of registering handleTime here, we should use select
    // to wait for a key with a timeout, and run handleTimer when
    // enough time for one frame has elapsed.

    // set up realtime interrupt timer and signals
    //game.myTimer.it_value.tv_sec = 0;
    //game.myTimer.it_value.tv_usec = 1000000 / FPS;
    //game.myTimer.it_interval.tv_sec = 0;
    //game.myTimer.it_interval.tv_usec = 1000000 / FPS;
    //setitimer(ITIMER_REAL, &game.myTimer, NULL);
    //signal(SIGALRM, handleTimer);

    while(1) {
        if( ( get_buttons() & 2 ) != 0 ) {
            if (game.state == STATE_INTRO) {
                game.lives = 3;
                game.score = 0;
                game.state = STATE_PLAY;
                resetShields();

                resetAliens();
                game.timer = 0;
                clear();
                paintShelters();

            } else if (game.state == STATE_PLAY
                    && game.timer > GUNNER_ENTRANCE
                    && gun.missile.y == 0) {
                gun.missile.x = gun.x;
                gun.missile.y = LINES - GUNNER_HEIGHT - 1;
            }
        }
        if( ( get_buttons() & 32 ) != 0 )
            gun.move = -2;
        if( ( get_buttons() & 64 ) != 0 )
            gun.move = 2;

        handleTimer( 1 );
     }

    return 0;   // not reached
}

void paintShelters() {
    int n, y, x;

#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(1) | A_BOLD );
#endif
    n = 0;
    for (y = 0; y < SHELTER_HEIGHT; y++) {
        move(LINES - 1 - SHELTER_HEIGHT - GUNNER_HEIGHT + y, 0);
        for (x = 0; x < game.screenCols; x++) {
            addch(gun.shields[n++]);
        }
    }
    refresh();
    attron( A_NORMAL );
}

/**
 * Handle timer signal.  This is the logic that moves all the sprites
 * around the screen.
 */
void handleTimer(int signal) {
    // TODO!  This should take a pointer to the game state, which points
    // to object on the stack of main, instead of accessing evil
    // global variables.
    int x;
    struct Bomb *b;

    // check which state the game is in
    if (game.state == STATE_INTRO) {
        // intro anim
        return;
    } else if (game.state == STATE_WAIT) {
        if (game.timer++ == 2) {
            game.state = STATE_PLAY;
            paintScore();
        }
        return;
    } else if (game.state == STATE_GAMEOVER) {
        if (game.timer++ == 4) {
            paintIntro();
            refresh();
            game.state = STATE_INTRO;
            SMTSTOP();
        }
        // game over anim
        return;
    } else if (game.state == STATE_EXPLODE) {
        // explode anim
        if (gun.explodeTimer++ % 4 == 0) {
            paintGunner();
        }
        if (gun.explodeTimer == 4) {
            if (game.lives-- == 0) {
                // game over
                game.state = STATE_GAMEOVER;
                game.timer = 0;
                mvprintw(LINES / 2, (COLS / 2) - 5, "GAME OVER");
                refresh();
                return;
            } else {
                // start next life
                // if the aliens have reached the shields
                // then move them back up to the top of the screen
                int lastLine = aliens.y + (ALIEN_HEIGHT * aliens.emptyBottom) - 1;
                int shieldTop = LINES - GUNNER_HEIGHT - SHELTER_HEIGHT - 1;
                if (lastLine >= shieldTop) aliens.y = 0;

                game.timer = 0;
                game.state = STATE_WAIT;
                ma.x = 0;   // just in case she was there at the time
                freeBombs();    // get rid of any bombs
                clear();
                paintShelters();
                refresh();
                aliens.paintRow = aliens.rows;
                return;
            }
        }
    }

    // otherwise handle game play...
    game.timer++;

    if (game.timer == GUNNER_ENTRANCE && game.state == STATE_PLAY) {
        paintGunner();
    }

    // decide if it's time to send on ma
    if (game.timer % MA_ENTRANCE == MA_ENTRANCE - 1 && aliens.y > 5) {
        ma.x = COLS - ALIEN_WIDTH - 1;
    }

    // if ma is currently on, display
    if (ma.x > 0) {
        int i;

#ifdef USE_COLORS
        if (has_colors()) attron(COLOR_PAIR(2) | A_BOLD);
#endif
        if (ma.pointsTimer != 0) {
            // ma has been shot and is now just showing points
            if (ma.pointsTimer++ == 4) {
                mvprintw(2, ma.x, "%s", alienBlank);
                ma.pointsTimer = 0;
                ma.x = 0;
            }
        } else {
            // ma is grooving across the top of the screen
            ma.x--;
            for (i = 0; i < MA_HEIGHT; i++)
                mvprintw(2 + i, ma.x, "%s ", alienMa[i]);
            refresh();
            // if we have reach the edge then remove ma
            if (ma.x == 0) {
                for (i = 0; i < MA_HEIGHT; i++)
                    mvprintw(2 + i, ma.x, "%s ", alienBlank);
            }
        }
        attron( A_NORMAL );
    }

    // drop bombs
    if (game.timer > GUNNER_ENTRANCE) {
        for (x = aliens.emptyLeft; x < aliens.emptyRight; x++) {
            int y;
            // find the first alien from the bottom
            for (y = aliens.emptyBottom - 1; y >= 0; y--) {
                if (aliens.table[(aliens.cols * y) + x] > ALIEN_EMPTY) {
                    if (rng(128) == 0) {
                        addBomb(aliens.x + (x * ALIEN_WIDTH) + (ALIEN_WIDTH / 2),
                            aliens.y + (y * ALIEN_HEIGHT) + ALIEN_HEIGHT - 1);
                    }
                    break;
                }
            }
        }
    }

    // handle gunner movements
    if (game.state == STATE_PLAY && game.timer > GUNNER_ENTRANCE) {
        if (gun.move < 0 && gun.x > GUNNER_WIDTH / 2) {
            gun.move++;
            gun.x--;
            paintGunner();
            refresh();
        }
        if (gun.move > 0 && gun.x < COLS - (GUNNER_WIDTH / 2)) {
            gun.move--;
            gun.x++;
            paintGunner();
            refresh();
        }
    }

    // handle alien movements
    if (--aliens.paintWait <= 0) {
        // time to repaint one row of aliens (speeds up as you shoot aliens)
        aliens.paintWait = (int) (PAINT_WAIT * (aliens.count / (aliens.cols * aliens.rows)));;
        aliens.paintRow--;
        paintAlienRow(aliens.paintRow, 0);
        refresh();

        if (aliens.paintRow <= aliens.emptyTop) {
            // time to move the block of aliens
            aliens.paintRow = aliens.emptyBottom;               // reset counter
            aliens.anim = (aliens.anim ? 0 : 1);    // wiggle
            if (aliens.direction == -1) {
                if (--aliens.x + (aliens.emptyLeft * ALIEN_WIDTH) == 0) {
                    // change direction, clear top line, shuffle down
                    aliens.direction = 1;
                    move(aliens.y, 0);
                    clrtoeol();
                    moveAliensDown();
                }
            } else if (aliens.direction == 1) {
                if (++aliens.x + (aliens.emptyRight * ALIEN_WIDTH) == COLS) {
                    // change direction, clear top line, shuffle down
                    aliens.direction = -1;
                    move(aliens.y, 0);
                    clrtoeol();
                    moveAliensDown();
                }
            }
            paintScore();
/*
            // see if the aliens have hit the bottom
            if (game.state == STATE_PLAY
                    && aliens.y + (ALIEN_HEIGHT *
                            (aliens.rows - aliens.emptyBottom))
                    > LINES - 1 - GUNNER_HEIGHT - SHELTER_HEIGHT) {
                game.state = STATE_EXPLODE;
                gun.explodeTimer = 0;
            }
*/
        }
    }

#ifdef USE_COLORS
    // use white for missiles and bombs
    if (has_colors()) attron(COLOR_PAIR(4));
#endif

    // handle bomb movements
    for (b = aliens.headBomb; b != NULL; ) {
        struct Bomb *next = b->next;
        move(b->y, b->x);
        addch(' ');
        if (++(b->y) < LINES) {
            if (gun.missile.y != 0
                    && abs(b->x - gun.missile.x) < 2
                    && abs(b->y - gun.missile.y) < 2) {
                // collision with missile
                removeBomb(b);
                move(gun.missile.y, gun.missile.x);
                addch(' ');
                gun.missile.y = 0;
            } else if (game.state == STATE_PLAY
                    && game.timer > GUNNER_ENTRANCE
                    && b->y >= LINES - GUNNER_HEIGHT
                    && b->x > (gun.x - (GUNNER_WIDTH / 2))
                    && b->x < (gun.x + (GUNNER_WIDTH / 2))) {
                // collision with gunner
                removeBomb(b);
#ifndef BULLET_PROOF
                game.state = STATE_EXPLODE;
                gun.explodeTimer = 0;
#endif
            } else if (b->y < LINES - 1 - GUNNER_HEIGHT
                && b->y >= LINES - 1 - GUNNER_HEIGHT - SHELTER_HEIGHT
                && gun.shields[((b->y - (LINES - 1 - GUNNER_HEIGHT - SHELTER_HEIGHT))
                    * game.screenCols) + b->x] != ' ') {
                // collision with shield
                gun.shields[((b->y - (LINES - 1 - GUNNER_HEIGHT
                                - SHELTER_HEIGHT))
                    * game.screenCols) + b->x] = ' ';
                mvaddch(b->y, b->x, ' ');
                removeBomb(b);
            } else {
                // advance bomb
                move(b->y, b->x);
                addch(bombAnim[b->anim++]);
                if (b->anim == BOMB_ANIM_SIZE) {
                    b->anim = 0;
                }
            }
        } else {
            removeBomb(b);
        }

        b = next;
        refresh();
    }

    // handle missile movements
    if (gun.missile.y != 0) {
        move(gun.missile.y, gun.missile.x);
        addch(' ');
        if ((gun.missile.y -= 2) > 0) {
            move(gun.missile.y, gun.missile.x);
            addch('!');
        } else {
            gun.missile.y = 0;
        }

        // test for collision with shield
        if (gun.missile.y < LINES - 1 - GUNNER_HEIGHT
                && gun.missile.y >= LINES - 1 - GUNNER_HEIGHT
                - SHELTER_HEIGHT) {
            if (gun.shields[((gun.missile.y - (LINES - 1 - GUNNER_HEIGHT
                    - SHELTER_HEIGHT))
                    * game.screenCols) + gun.missile.x] != ' ') {
                gun.shields[((gun.missile.y - (LINES - 1 - GUNNER_HEIGHT
                    - SHELTER_HEIGHT))
                    * game.screenCols) + gun.missile.x] = ' ';

                mvaddch(gun.missile.y, gun.missile.x, ' ');
                gun.missile.y = 0;
            }
        }

        // test for collision with aliens
        else if (gun.missile.x >= aliens.x && gun.missile.x < aliens.x
                + (ALIEN_WIDTH * aliens.cols)
            && gun.missile.y < aliens.y + ALIEN_HEIGHT * aliens.rows &&
                gun.missile.y >= aliens.y) {
            int alien;
            int x = gun.missile.x - aliens.x;
            int y = gun.missile.y - aliens.y;
            if (x % ALIEN_WIDTH != 0 && x % ALIEN_WIDTH != ALIEN_WIDTH -1) {
                // it didn't sneak between two aliens
                x = x / ALIEN_WIDTH;
                y = y / ALIEN_HEIGHT;
                alien = aliens.table[(y * aliens.cols) + x];
                if (alien > ALIEN_EMPTY) {
                    game.score += alien * 10;
                    paintExplodingAlien(y, x);
                    paintScore();
                    gun.missile.y = 0;   // no more missile
                    aliens.table[(y * aliens.cols) + x] = ALIEN_EXPLODE1;
                    if (--aliens.count == 0) {
                        resetAliens();
                        game.timer = 0;
                        clear();
                        paintShelters();
                    }
                    refresh();
                    trimAliens();
                }
            }
        }

        // test for collection with ma
        else if (ma.x != 0
                && gun.missile.y <= 2 + MA_HEIGHT
                && gun.missile.x >= ma.x
                && gun.missile.x <= ma.x + ALIEN_WIDTH) {
            // chose a 'random' number of points, either 50, 100 or 150
            int points = ((systemclock() % 3) + 1) * 50;
            int i;
            game.score += points;
            // remove ma
            for (i = 0; i < MA_HEIGHT; i++)
                mvprintw(2 + i, ma.x, "%s ", alienBlank);
            // draw the number of points
            mvprintw(2, ma.x, "  %d", points);
            ma.pointsTimer = 1;
            paintScore();
        }

        refresh();
    }
}

/**
 * Move aliens down one row.
 */
void moveAliensDown() {
    // figure out which screen row the bottom alien is one
    // and if it's over the sheilds then clear the line of
    // the shields or at the bottom of the screen
    int lastLine = ++aliens.y + (ALIEN_HEIGHT * aliens.emptyBottom) - 1;
    int topShield = LINES - GUNNER_HEIGHT - SHELTER_HEIGHT - 1;
    int gunnerTop = LINES - GUNNER_HEIGHT - 1;

    if (lastLine >= topShield && lastLine < topShield + SHELTER_HEIGHT) {
        // clear the shield line
        int i = (lastLine - topShield) * game.screenCols;
        int j;
        for (j = 0; j < game.screenCols; j++) {
            gun.shields[i + j] = ' ';   // DEBUG
        }
        paintShelters();
    }
    if (lastLine == gunnerTop) {
        // blow up gunner if not already blowing up
        if (game.state != STATE_EXPLODE) {
            game.state = STATE_EXPLODE;
            gun.explodeTimer = 0;
        }
    }
}

/**
 * Adjusts the size of the block of aliens for left and right (the bottom
 * adjustment is made by the alien drawing code).
 */
void trimAliens() {
    // update empty line pointers
    int found = 0;
    for (;;) {
        int i;
        for (i = 0; i < aliens.rows; i++) {
            if (aliens.table[(i * aliens.cols) + aliens.emptyLeft]
                    != ALIEN_EMPTY) {
                found = 1;
                break;
            }
        }
        if (found) break;
        else aliens.emptyLeft++;
    }

    found = 0;
    for (;;) {
        int i;
        for (i = 0; i < aliens.rows; i++) {
            if (aliens.table[(i * aliens.cols) + aliens.emptyRight - 1]
                    != ALIEN_EMPTY) {
                found = 1;
                break;
            }
        }
        if (found) break;
        else aliens.emptyRight--;
    }

    found = 0;
    for (;;) {
        int i;
        for (i = 0; i < aliens.cols; i++) {
            if (aliens.table[((aliens.emptyBottom - 1) * aliens.cols) + i]
                    != ALIEN_EMPTY) {
                found = 1;
                break;
            }
        }
        if (found) break;
        else aliens.emptyBottom--;
    }
}

/**
 * Ends and tidies up.
 */
void cleanUp(int signal) {
    if (aliens.table != NULL) free(aliens.table);
    if (gun.shields != NULL) free(gun.shields);
    endwin();
}

void paintGunner() {
    int i;
#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(1));
#endif
    for (i = 0; i < GUNNER_HEIGHT; i++) {
        move(LINES - GUNNER_HEIGHT + i, gun.x - (GUNNER_WIDTH / 2));
        if (game.state == STATE_PLAY) {
            printw("%s", gunner[i]);
        } else if (game.state == STATE_EXPLODE) {
            printw("%s", gunnerExplode[i + (GUNNER_HEIGHT
                            * ((game.timer / 4) % 2))]);
        }
    }
}

void paintExplodingAlien(int y, int x) {
    int i;
    for (i = 0; i < ALIEN_HEIGHT; i++) {
        move((y * ALIEN_HEIGHT) + aliens.y + i, (x * ALIEN_WIDTH) + aliens.x
            + (y > aliens.paintRow ? aliens.direction : 0));
                // adjustment because of
                // alien drawing technique
        printw("%s", alienExplode[i]);
    }
}

void removeAlien(int y, int x) {
    int i;
    for (i = 0; i < ALIEN_HEIGHT; i++) {
        move((y * ALIEN_HEIGHT) + aliens.y + i, (x * ALIEN_WIDTH) + aliens.x);
        printw("%s", alienBlank);
    }
}

void paintScore() {
#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(4));
#endif
    if (aliens.y > 0) {
        move(0, 0);
        printw("Ascii-Invaders  Score: %d   Lives remaining: %d", game.score,
                game.lives);
    }
}

/**
 * Paints a row of aliens (but doesn't call refresh).
 * @param row which row of aliens to draw
 * @param clean whether to paint the line above this row of aliens white
 */
void paintAlienRow(int row, int clean) {
    int x, i;

    if (clean) {
        move((row * ALIEN_HEIGHT) + aliens.y - 1, 0);
        deleteln();
    }
    // draw the alien space ships
#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(4));
#endif
    // this is a slight kludge - occasionally bits of explosion were left
    // behind when the aliens were moving and exploding at the same time, so:
    // if we are not right against the left or right of the screen,
    // we delete the column immediately before and after each line
    if (aliens.x > 0) {
        for (i = 0; i < ALIEN_HEIGHT; i++) {
            move((row * ALIEN_HEIGHT) + aliens.y + i,
                    (aliens.emptyLeft * ALIEN_WIDTH) + aliens.x - 1);
            addch(' ');
        }
    }
    if (aliens.x + (ALIEN_WIDTH * aliens.emptyRight) < game.screenCols) {
        for (i = 0; i < ALIEN_HEIGHT; i++) {
            move((row * ALIEN_HEIGHT) + aliens.y + i,
                    (aliens.emptyRight * ALIEN_WIDTH) + aliens.x);
            addch(' ');
        }
    }

    // draw the aliens
    for (x = aliens.emptyLeft; x < aliens.emptyRight; x++) {
        int line = ALIEN_HEIGHT * aliens.anim;
        int alien = aliens.table[(row * aliens.cols) + x];
        for (i = 0; i < ALIEN_HEIGHT; i++) {
            move((row * ALIEN_HEIGHT) + aliens.y + i,
                    (x * ALIEN_WIDTH) + aliens.x);
            switch (alien) {
                case ALIEN10:
                    printw("%s", alien10[line + i]);
                    break;
                case ALIEN20:
                    attron(COLOR_PAIR(3));
                    printw("%s", alien20[line + i]);
                    attron(COLOR_PAIR(4));
                    break;
                case ALIEN30:
                    attron(COLOR_PAIR(6));
                    printw("%s", alien30[line + i]);
                    attron(COLOR_PAIR(4));
                    break;
                case ALIEN_EXPLODE1:
                    //printw("%s", alienExplode[i]);
                    // do nothing, to leave the explosion on the screen
                    break;
                case ALIEN_EXPLODE2:
                case ALIEN_EMPTY:
                    // wipe out
                    printw("%s", alienBlank);
            }
        }
        // if the alien is exploding then advance its explosion state
        if (alien == ALIEN_EXPLODE1) {
            aliens.table[(row * aliens.cols) + x] = ALIEN_EXPLODE2;
        } else if (alien == ALIEN_EXPLODE2) {
            aliens.table[(row * aliens.cols) + x] = ALIEN_EMPTY;
            trimAliens();
        }
    }
}

void initGame() {
    //memset(&game,0,sizeof(game));
    //memset(&aliens,0,sizeof(aliens));
    //memset(&gun,0,sizeof(gun));
    //memset(&ma,0,sizeof(ma));

    aliens.cols = (COLS / ALIEN_WIDTH) - 4;
    aliens.rows = ((LINES/2) / ALIEN_HEIGHT) - 4;
    aliens.table = malloc(aliens.cols * aliens.rows * sizeof(int));
    gun.shields = malloc(game.screenCols * SHELTER_HEIGHT);
}

void paintIntro() {
    clear();

#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(4));
#endif
    mvprintw(2, (COLS / 2) - 30, "                _ _   _                     _               ");
    mvprintw(3, (COLS / 2) - 30, "  __ _ ___  ___(_|_) (_)_ ____   ____ _  __| | ___ _ __ ___ ");
    mvprintw(4, (COLS / 2) - 30, " / _` / __|/ __| | | | | '_ \\ \\ / / _` |/ _` |/ _ \\ '__/ __|");
    mvprintw(5, (COLS / 2) - 30, "| (_| \\__ \\ (__| | | | | | | \\ V / (_| | (_| |  __/ |  \\__ \\");
    mvprintw(6, (COLS / 2) - 30, " \\__,_|___/\\___|_|_| |_|_| |_|\\_/ \\__,_|\\__,_|\\___|_|  |___/");


#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(2) | A_BOLD );
#endif
    mvprintw( 9, (COLS / 2) - 8, alienMa[0]);
    mvprintw(10, (COLS / 2) - 8, alienMa[1]);
#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(4) | A_NORMAL );
#endif
    mvprintw( 9, (COLS / 2), "= ?  points");

    mvprintw(12, (COLS / 2) - 8, alien30[0]);
    mvprintw(13, (COLS / 2) - 8, alien30[1]);
    mvprintw(12, (COLS / 2), "= 30 points");

    mvprintw(15, (COLS / 2) - 8, alien20[0]);
    mvprintw(16, (COLS / 2) - 8, alien20[1]);
    mvprintw(15, (COLS / 2), "= 20 points");

    mvprintw(18, (COLS / 2) - 8, alien10[0]);
    mvprintw(19, (COLS / 2) - 8, alien10[1]);
    mvprintw(18, (COLS / 2), "= 10 points");

#ifdef USE_COLORS
    if (has_colors()) attron(COLOR_PAIR(1));
#endif
    mvprintw(LINES - 1, (COLS - 41) / 2, "https://github.com/macdice/ascii-invaders");
    refresh();
}

void resetAliens() {
    int x, y = 0;

    // we make one row of alien30s...
    for (x = 0; x < aliens.cols; x++)
        aliens.table[x] = ALIEN30;

    // next we fill half of the remaining rows with alien20s...
    while (++y < (aliens.rows / 2))
        for (x = 0; x < aliens.cols; x++)
            aliens.table[(y * aliens.cols) + x] = ALIEN20;

    // next we stick in some alien10s...
    do
        for (x = 0; x < aliens.cols; x++)
            aliens.table[(y * aliens.cols) + x] = ALIEN10;
    while (++y < aliens.rows);

    aliens.emptyLeft = aliens.emptyTop = 0;
    aliens.emptyRight = aliens.cols;
    aliens.emptyBottom = aliens.rows;

    aliens.x = aliens.y = 0;
    aliens.direction = 1;
    aliens.paintWait = PAINT_WAIT;
    aliens.paintRow = aliens.rows;
    aliens.count = aliens.cols * aliens.rows;
    freeBombs();

    ma.x = 0;

    gun.x = COLS / 2;
    gun.missile.x = gun.missile.y = 0;
}

/**
 * Sets up the shields.
 */
void resetShields() {
    int x, y;
    for (y = 0; y < SHELTER_HEIGHT * game.screenCols; gun.shields[y++] = ' ');
    for (x = 0; x < game.screenCols - 10; x += 10) {
        for (y = 0; y < SHELTER_HEIGHT; y++) {
            int i = 0;
            while (shelter[y][i] != 0) {
                gun.shields[(y * game.screenCols) + x + i] = shelter[y][i];
                i++;
            }
        }
    }
}

/**
 * Add a bomb to the linked list of bombs.
 * @param x the x coordinate
 * @param y the y coordinate
 */
void addBomb(int x, int y) {
    struct Bomb *b;
    b = malloc(sizeof(struct Bomb));
    if (b == NULL) {
	/* If we run out of memory, just don't add a bomb.
	 * Well overcommit likely means this never happens, and
	 * instead in the event of memory shortage b will not be NULL
	 * but will not have physical memory available and we'll just crash
	 * when we attempt to access it.  But this shuts scan-build up. */
	return;
    }
    b->x = x;
    b->y = y;
    b->anim = 0;
    b->next = aliens.headBomb;
    aliens.headBomb = b;
}

/**
 * Remove a bomb from the linked list of bombs.
 * @param b bomb pointer
 * @return whether the bomb was found
 */
int removeBomb(struct Bomb *b) {
    struct Bomb *this;
    struct Bomb *last;

    // see if it's illegal to search
    if (b == NULL || aliens.headBomb == NULL)
        return 0;

    // see if it's the first one
    if (aliens.headBomb == b) {
        aliens.headBomb = b->next;
        free(b);
        return 1;
    }

    // no, look for it in the list
    for (this = aliens.headBomb, last = NULL;
            this != NULL;
            last = this, this = this->next) {

        if (this == b) {
            last->next = this->next;
            free(this);
            return 1;
        }
    }

    // couldn't find it
    return 0;
}

/**
 * Free all alien bombs.
 */
void freeBombs() {
    while (aliens.headBomb)
        removeBomb(aliens.headBomb);
}
