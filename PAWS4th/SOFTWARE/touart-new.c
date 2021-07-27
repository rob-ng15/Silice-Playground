#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <termios.h>

// FROM https://stackoverflow.com/questions/6947413/how-to-open-read-and-write-from-serial-port-in-c
int set_interface_attribs (int fd, int speed, int parity) {
        struct termios tty;
        if (tcgetattr (fd, &tty) != 0) {
            printf("error %d from tcgetattr\n", errno);
            return -1;
        }

        cfsetospeed (&tty, speed);
        cfsetispeed (&tty, speed);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0) {
            printf("error %d from tcsetattr\n", errno);
            return -1;
        }
        return 0;
}

void set_blocking (int fd, int should_block) {
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0) {
            printf("error %d from tggetattr\n", errno);
            return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
            printf("error %d setting term attributes\n", errno);
}

void File_Copy(char *filename, int destFile){
    int fd; char c, line[80]; int position;
    fd = open(filename, O_RDONLY); //opening files to be read/created and written to

    position = 0;
    while(read(fd , &c, 1) != 0){
        if( c == 0x0a ) c = 0;
        line[position++] = c;
        if( c == 0 ) {
            position = 0;
            if( line[position] == '#' ) {
                File_Copy( &line[1], destFile );
            } else {
                while( line[position] != 0 ) {
                    c = line[position++];
                    write(destFile , &c, 1);
                    usleep( 2500 );
                }
                c = 0x0d;
                write(destFile , &c, 1);
                position = 0;
            }
        }
    }

    close( fd );
}

int main( int argc, char *argv[] ){
    int fd_destination;
    fd_destination = open(argv[2], O_RDWR);
    set_interface_attribs (fd_destination, B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
    set_blocking (fd_destination, 0);                // set no blocking

    File_Copy(argv[1], fd_destination); //copy function

    close(fd_destination);
    return 0;
}
