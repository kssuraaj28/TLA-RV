#include <cstdint>
#include <iostream>
#include <mutex>
#include <thread>
#include <unistd.h>

int32_t thread1_in_cs;
int32_t thread2_in_cs;

void update_refinement(int32_t t1, int32_t t2) {
  thread1_in_cs = t1;
  thread2_in_cs = t2;
}

std::mutex lock;
void critical_section(int thread_id) {
  for (int i = 0; i < 100; i++) {

    for (int j = 0; j < 10000; j++)
      ;
    // CS Starts
    {
#ifdef ENABLE_MUTEX
      std::lock_guard<std::mutex> lg{lock};
#endif
      if (thread_id == 1)
        update_refinement(1, thread2_in_cs);
      else
        update_refinement(thread1_in_cs, 1);

      // Do work
      for (int j = 0; j < 10000; j++)
        ;

      if (thread_id == 1)
        update_refinement(0, thread2_in_cs);
      else
        update_refinement(thread1_in_cs, 0);
    }
  }
}

int main() {
  std::thread t1(critical_section, 1);
  std::thread t2(critical_section, 2);

  t1.join();
  t2.join();
}
