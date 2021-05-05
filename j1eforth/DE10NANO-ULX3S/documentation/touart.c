#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

void File_Copy(int sourceFile, int destFile, int n){
    char c;

    while(read(sourceFile , &c, 1) != 0){
        if( c == 0x0a ) c = 0x0d;
        write(destFile , &c, 1);
        usleep( 100000 );
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
