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



void File_Copy(int sourceFile, int destFile, int n){
    char c;

    while(read(sourceFile , &c, 1) != 0){
        if( c == 0x0a ) c = 0x0d;
        write(destFile , &c, 1);
        usleep( 2500 );
    }
}

int main( int argc, char *argv[] ){
    int fd, fd_destination;
    fd = open(argv[1], O_RDONLY); //opening files to be read/created and written to
    fd_destination = open(argv[2], O_RDWR);

    set_interface_attribs (fd_destination, B115200, 0);  // set speed to 115,200 bps, 8n1 (no parity)
    set_blocking (fd_destination, 0);                // set no blocking

    clock_t begin = clock(); //starting clock to time the copying function

    File_Copy(fd, fd_destination, 100); //copy function

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC; //timing display

return 0;
}
