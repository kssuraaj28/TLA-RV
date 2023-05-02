#include <stdio.h>
#include <stdlib.h>

int x;
int y;

void update_refinement(int new_x, int new_y) {
  x = new_x;
  y = new_y;
}

int main(int argc, char *argv[]) {
  x = atoi(argv[1]);
  y = atoi(argv[2]);
  while (y != 0) {
    update_refinement(y, x % y);
  }
  printf("GCD is %d\n", x);
}
