#include <iostream>
#include <span>
#include <vector>

void process(std::span<const int> data) {
    for (int n : data) std::cout << n << " ";
}

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5};
    process(v);
    return 0;
}
