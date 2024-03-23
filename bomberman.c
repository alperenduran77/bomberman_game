#include <stdio.h>
#include <stdlib.h>
  int r,c;
    char map1[200][200];
    char map2[200][200];
void read()
{
 //Read
    scanf("%d %d",&r,&c);
    for(int i=0;i<r;i++)
    {
        scanf("%s",map1[i]);
        for(int j=0;j<c;j++)
        {
            map2[i][j]='O';  
        }
    }
}
void solve()
{
//Mark
    for(int i=0;i<r;i++)
    {
        for(int j=0;j<c;j++)
        {
            if(map1[i][j]=='O')
            {
                map2[i][j]='.';
                map2[i][j-1]='.';
                map2[i][j+1]='.';
                map2[i-1][j]='.';
                map2[i+1][j]='.';
            }
        }
    }
}
void print()
{
  //PRİNT
  printf("---MAP---\n");
        for(int i=0;i<r;i++)
        {
            for(int j=0;j<c;j++)
            {
                printf("%c",map2[i][j]);
            }
            printf("\n");
        }
    
}
int main() {   
   read();
   solve();
   print();  
    return 0;
}