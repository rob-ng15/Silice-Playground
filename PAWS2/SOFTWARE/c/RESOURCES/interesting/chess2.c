//https://www.quora.com/How-can-I-make-a-simple-console-chess-game-with-C-read-details

#include<iostream>
#include<string.h>
#include <windows.h>
using namespace std;
HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
COORD CursorPosition;
struct coordinate
{
    char x;
    int y;
};
struct pieceInfo
{
    string pieceType;
    string pieceName;
    coordinate location;
};
struct update
{
    coordinate initial;
    coordinate finale;
};
void gotoXY(int x,int y);
void generateBoard(pieceInfo allLocations[]);
void markPiece(pieceInfo allLocations[]);
void generateHorizontalLine(int x, int y, int length, int rowNum);
void generateVerticalLine(int x, int y, int length, int colNum);
void updateCurrentLocation(update newMove, pieceInfo currentLocation[]);
int main()
{
    int moveCheck=0;
    string moveInput;
    pieceInfo initializeBoard[]= { {"Black","Rook",{'a',8}}, {"Black","Rook",{'h',8}}, {"While","King",{'e',1}} };
    pieceInfo currentLocation[]= { {"Black","Rook",{'a',8}}, {"Black","Rook",{'h',8}}, {"While","King",{'e',1}} };
    update newMove;
    generateBoard(initializeBoard);
    while(true)
    {
        if(moveCheck%2==0)
        {
            cout<<"BLACK MOVES :- ";
        }
        else
        {
             cout<<"WHITE MOVES :- ";
        }
        cin>>moveInput;
        newMove.initial.x= moveInput[0];
        newMove.initial.y= moveInput[1]- '0';
        newMove.finale.x= moveInput[2];
        newMove.finale.y= moveInput[3]- '0';
        updateCurrentLocation(newMove, currentLocation);
        generateBoard(currentLocation);
        moveCheck++;
    }
    return 0;
}
void generateBoard(pieceInfo allLocations[])
{
    system("cls");
    for(int i=1; i<=9; i++)
       generateHorizontalLine(6,3*i,32,i);
    for(int i=0; i<=8; i++)
        generateVerticalLine(6+8*i,3,25,i);
    markPiece(allLocations);
}
void markPiece(pieceInfo allLocations[])
{
    for(int i=0; i<3; i++)
    {
        int x= (allLocations[i].location.x - 'a')*8 + 10;
        int y= (allLocations[i].location.y - 1)*3 + 5;
        gotoXY(x,y);
        if(allLocations[i].pieceName=="Rook")
        {
            cout<<"R";
        }
        else if(allLocations[i].pieceName=="King")
        {
            cout<<"K";
        }
    }
    gotoXY(1,30);
}
void updateCurrentLocation(update newMove, pieceInfo currentLocation[])
{
    for(int i=0; i<3; i++)
    {
        if(newMove.initial.x==currentLocation[i].location.x && newMove.initial.y==currentLocation[i].location.y)
        {
            currentLocation[i].location.x=newMove.finale.x;
            currentLocation[i].location.y=newMove.finale.y;
        }
    }
}
void gotoXY(int x, int y)
{
    CursorPosition.X = x;
    CursorPosition.Y = y;
    SetConsoleCursorPosition(console,CursorPosition);
}
void generateHorizontalLine(int x, int y, int length, int rowNum)
{
    if(rowNum<9)
    {
    gotoXY(x-2,y+2);
    cout<<rowNum;
    }
    gotoXY(x,y);
    for(int i=0; i<length; i++)
        cout<<"--";
    if(rowNum<9)
    {
    gotoXY(72,y+2);
    cout<<rowNum;
    }
}
void generateVerticalLine(int x, int y, int length, int colNum)
{
    if(colNum<8)
    {
    gotoXY(x+4, y-1);
    cout<<char(colNum+'a');
    }
    for(int i=0; i<length; i++)
    {
        gotoXY(x,y+i);
        cout<<"|";
    }
    if(colNum<8)
    {
    gotoXY(x+4, 28);
    cout<<char(colNum+'a');
    }
