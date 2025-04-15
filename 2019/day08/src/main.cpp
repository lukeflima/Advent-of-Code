#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <vector>
#include <algorithm>
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
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    std::vector<std::string_view> layers;
    for(size_t i = 0; i < input.size(); i += 25*6) {
        layers.push_back(input.substr(i, 25*6));
    }
    auto min_layer = layers[0];
    auto min_layer_count = std::ranges::count(min_layer, '0');;
    for(auto layer : layers) {
       auto count_0 = std::ranges::count(layer, '0');;
       if(count_0 < min_layer_count) {
           min_layer = layer;
           min_layer_count = count_0;
       }
    }
    return std::to_string(std::ranges::count(min_layer, '1') * std::ranges::count(min_layer, '2'));
}

std::string part2(const std::string_view input) {
    std::vector<std::string_view> layers;
    for(size_t i = 0; i < input.size(); i += 25*6) {
        layers.push_back(input.substr(i, 25*6));
    }
    std::string image_line(25*6, ' ');
    for(size_t i = 0; i < image_line.size(); i++) {
        for(auto layer : layers) {
            if(layer[i] != '2') {
                image_line[i] = layer[i] == '0' ? ' ' : '#';
                break;
            }
        }
    }

    std::string image;
    for(size_t i = 0; i < image_line.size(); i += 25) {
        image += "\n" + image_line.substr(i, 25);
    }
    
    return image;
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