// This is the runtime library for logging. Right now, we only support integers
#include <iostream>
#include <vector>

namespace {
void print_vect(std::vector<int> &nums) {
  for (int i = 0; i < nums.size(); i++) {
    if (i != 0) {
      std::cout << ", ";
    }
    std::cout << nums[i];
  }
}
struct Logger {
  using state = std::vector<int>;
  std::vector<state> collected_states;
  state current_state;
  ~Logger() {
    for (auto &state : collected_states) {
      std::cout << "~~";
      print_vect(state);
    }
    std::cout << std::endl;
  }
};

Logger x;
} // namespace

extern "C" {
void log_into_state(int v) { x.current_state.push_back(v); }

void log_next_state() {
  x.collected_states.push_back(
      std::move(x.current_state)); // This should make the current state empty
}
}
