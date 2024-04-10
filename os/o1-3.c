#include <stdio.h>

struct point
{
    int x;
    int y;
    int z;
};

int main()
{
    struct point pArray[4] = {{0,0,0},{0,0,0},{0,0,0},{0,0,0}};
    pArray[1].z=1025;
    int *i = (int *)(pArray + 1);
    *i = 4;
    i = (int *)(((void *)i)+9);
    char *c = (char *) i;
    printf("c: %d\n", *c)
    *((int *)(c+4)+1)=5;
    printf("%d\n", pArray[2].y);
}