#include <cstdint>

void func() {}

//void refinement_uate() {}
//
void refinement_update(int32_t x, int32_t y, int32_t z) {}

//void refinement_update(int32_t x) {}

int main() {
  refinement_update(3,4,1);
  refinement_update(3,4,1);
  refinement_update(3,4,0);
  return 0;
}
