// This is the runtime library for logging. Right now, we only support integers
#include <fstream>
#include <mutex>
#include <vector>

namespace {
void print_vect(std::ofstream& stream, std::vector<int> &nums) {
  for (int i = 0; i < nums.size(); i++) {
    if (i != 0) {
      stream << ", ";
    }
    stream << nums[i];
  }
}

constexpr char loggerfile[]{"logger_trace.txt"};

struct Logger {
  using state = std::vector<int>;
  std::mutex lock;
  std::vector<state> collected_states;
  state current_state;
  Logger() : current_state{}, collected_states{} {}
  ~Logger() {
    std::ofstream myfile;
    myfile.open(loggerfile);
    for (auto &state : collected_states) {
      print_vect(myfile,state);
      myfile << "\n";
    }
    myfile.close();
  }
};

Logger x{};
} // namespace

extern "C" {
void begin_next_state() { x.lock.lock(); }
void log_into_state(int v) { x.current_state.push_back(v); }

void log_next_state() {
  x.collected_states.push_back(
      std::move(x.current_state)); // This should make the current state empty
  x.lock.unlock();
}
}
