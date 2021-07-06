#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <termios.h>

int set_baudrate(int fd, speed_t speed)
{
    struct termios tty;
    int rc1, rc2;

    if (tcgetattr(fd, &tty) < 0) {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return -1;
    }
    rc1 = cfsetospeed(&tty, speed);
    rc2 = cfsetispeed(&tty, speed);
    if ((rc1 | rc2) != 0 ) {
        printf("Error from cfsetxspeed: %s\n", strerror(errno));
        return -1;
    }
    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return -1;
    }
    tcflush(fd, TCIOFLUSH);  /* discard buffers */

    return 0;
}

void File_Copy(int sourceFile, int destFile, int n){
    char c;

    while(read(sourceFile , &c, 1) != 0){
        if( c == 0x0a ) c = 0x0d;
        write(destFile , &c, 1);
        usleep( 1000 );
    }
}

int main( int argc, char *argv[] ){
    int fd, fd_destination;
    fd = open(argv[1], O_RDONLY); //opening files to be read/created and written to
    fd_destination = open(argv[2], O_RDWR);

    clock_t begin = clock(); //starting clock to time the copying function

    File_Copy(fd, fd_destination, 100); //copy function

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC; //timing display

return 0;
}
