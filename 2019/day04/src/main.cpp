#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <vector>
#include <ranges>
#include <algorithm>
namespace fs = std::filesystem;

std::string strip(std::string_view s) {
    size_t spaces_start = 0;
    while (std::isspace(s[spaces_start])) spaces_start++;
    size_t spaces_end = s.size();
    while (std::isspace(s[spaces_end - 1])) spaces_end--;
    return std::string(s.substr(spaces_start, spaces_end));
}

std::vector<std::string> split(std::string_view s_input, std::string_view delimiter) {
    std::vector<std::string> result;
    auto s = std::string(s_input);
    unsigned long prev = 0;
    for(unsigned long i = s.find(delimiter); i != s.npos; i = s.find(delimiter, prev)) {
        result.push_back(s.substr(prev, i));
        prev = i + 1;
    }
    if(s.length() > 0) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    auto nums = split(input, "-")
        | std::views::transform([](auto s) {return std::stoi(s);})
        | std::ranges::to<std::vector<size_t>>();

    int res = 0;
    for(size_t i = nums[0]; i <= nums[1]; i++) {
        auto s = std::to_string(i);
        bool has_double = false;
        bool increasing = true;
        for(size_t j = 0; j < s.length() - 1; j++) {
            if(s[j] == s[j + 1]) {
                has_double = true;
            }
            if(s[j] > s[j + 1]) {
                increasing = false;
                break;
            }
        }
        if(has_double && increasing) {
            res += 1;
        }
    }
    return std::to_string(res);
}

std::string part2(const std::string_view input) {
    auto nums = split(input, "-")
        | std::views::transform([](auto s) {return std::stoi(s);})
        | std::ranges::to<std::vector<size_t>>();
    int res = 0;
    for(size_t i = nums[0]; i <= nums[1]; i++) {
        auto s = std::to_string(i);
        bool has_double = false;
        bool increasing = true;
        std::vector<size_t> counts(10, 0);
        for(size_t j = 0; j < s.length() - 1; j++) {
            counts[s[j] - '0']++;
            if(s[j] == s[j + 1]) {
                has_double = true;
            }
            if(s[j] > s[j + 1]) {
                increasing = false;
                break;
            }
        }
        counts[s[s.length() - 1] - '0']++;
        if(has_double && increasing) {
            for(auto count : counts) {
                if(count == 2) {
                    res += 1;
                    break;
                }
            }
        }
    }
    return std::to_string(res);
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