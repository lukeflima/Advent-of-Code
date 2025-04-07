#include <ranges>
#include <algorithm>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <vector>
#include <cmath>
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
        prev = i + 1;
    }
    if(s.length() > 0) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    auto lines = split(input, "\n");
    auto fuels = lines
        | std::views::transform([](std::string s) { return std::stoull(s); }) 
        | std::views::transform([](auto mass) { return (mass/3) - 2; });
    auto sum = std::ranges::fold_left(fuels, 0ULL, std::plus<unsigned long long>());
    return std::to_string(sum);
}

std::string part2(const std::string_view input) {
    auto lines = split(input, "\n");
    auto fuels = lines
        | std::views::transform([](std::string s) { return std::stoull(s); })
        | std::ranges::to<std::vector>();
    unsigned long long res = 0;
    while (fuels.size() > 0) {
        fuels = fuels
            | std::views::transform([](auto mass) { return (mass/3); })
            | std::views::filter([](auto fuel) { return fuel>2; })
            | std::views::transform([](auto fuel) { return fuel-2; })
            | std::ranges::to<std::vector>();
            res += std::ranges::fold_left(fuels, 0ULL, std::plus<unsigned long long>());
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