#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <vector>
#include <ranges>
namespace fs = std::filesystem;

std::string strip(std::string_view s) {
    size_t spaces_start = 0;
    while (std::isspace(s[spaces_start])) spaces_start++;
    size_t spaces_end = s.size();
    while (std::isspace(s[spaces_end - 1])) spaces_end--;
    return std::string(s.substr(spaces_start, spaces_end - spaces_start));
}

std::vector<std::string> split(std::string_view s_input, std::string_view delimiter) {
    std::vector<std::string> result;
    auto s = std::string(s_input);
    unsigned long prev = 0;
    for(unsigned long i = s.find(delimiter); i != s.npos; i = s.find(delimiter, prev)) {
        result.push_back(s.substr(prev, i - prev));
        prev = i + delimiter.length();
    }
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    auto numbers = std::string(input.data()) | std::views::transform([](char s) { return int(s) - int('0'); }) | std::ranges::to<std::vector<int>>();
    int sequence[] = {0, 1, 0, -1};
    const int phases = 100;
    for(int phase = 0; phase < phases; phase++) {
        std::vector<int> new_numbers(numbers.size());
        for(size_t i = 1; i <= numbers.size(); i++) {
            int sum = 0;
            for(size_t j = 1; j <= numbers.size(); j++) {
                size_t sequence_index = (j/i) % 4;
                sum += numbers[j-1] * sequence[sequence_index];
            }
            new_numbers[i-1] = std::abs(sum) % 10;
        }
        numbers = new_numbers;
    }
    return std::format("{}{}{}{}{}{}{}{}", numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], numbers[6], numbers[7]);
}

std::string part2(const std::string_view input) {
    auto numbers = std::string(input.data()) | std::views::transform([](char s) { return int(s) - int('0'); }) | std::ranges::to<std::vector<int>>();
    const int repeat = 10000;
    const int total_size = numbers.size() * repeat;
    std::vector<int> big_numbers(total_size);
    
    for(int i = 0; i < repeat; i++) {
        for(size_t j = 0; j < numbers.size(); j++) {
            big_numbers[i * numbers.size() + j] = numbers[j];
        }
    }
    int offset = 0;
    for(int i = 0; i < 7; i++) {
        offset = offset * 10 + big_numbers[i];
    }
    const int phases = 100;
    for(int phase = 0; phase < phases; phase++) {
        int sum = 0;
        for(int i = total_size - 1; i >= offset; i--) {
            sum = (sum + big_numbers[i]) % 10;
            big_numbers[i] = sum;
        }
    }
    return std::format("{}{}{}{}{}{}{}{}", big_numbers[offset], big_numbers[offset+1], big_numbers[offset+2], big_numbers[offset+3], big_numbers[offset+4], big_numbers[offset+5], big_numbers[offset+6], big_numbers[offset+7]);
}

int main(int argc, char **argv) {
    if(argc != 2) {
        std::print("Usage: {} file_name", argv[0]);
        return -1;
    }
    const auto file_path = argv[1];

    auto size = fs::file_size(file_path);
    std::string input(size, '\0');
    std::ifstream input_file(file_path);
    input_file.read(&input[0], size);
    input = strip(input);
    
    std::println("Part 1: {}", part1(input));
    std::println("Part 2: {}", part2(input));

    return 0;
}