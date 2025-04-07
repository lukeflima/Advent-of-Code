#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <vector>
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
    if(prev < s.size()) result.push_back(s.substr(prev));
    return result;
}

struct Node {
    std::string name;
    std::vector<size_t> children;
};

std::string part1(const std::string_view input) {
    std::unordered_map<std::string, std::vector<std::string>> graph;
    for(auto line: split(input, "\n")){
        auto edge = split(line, ")");
        graph[edge[0]].push_back(edge[1]);
        graph[edge[1]].push_back(edge[0]);        
    }
    long long res = 0;
    struct State { long long orbs; std::string name; };
    std::queue<State> queue;
    std::unordered_set<std::string> visited;
    queue.push({0, "COM"});
    while(!queue.empty()){
        auto [orbs, name] = queue.front();
        queue.pop();
        if (visited.find(name) != visited.end()) continue;
        visited.insert(name);
        res += orbs;
        for(auto child: graph[name]){
            queue.push({orbs + 1, child});
        }
    }
    return std::to_string(res);
}

std::string part2(const std::string_view input) {
    std::unordered_map<std::string, std::vector<std::string>> graph;
    for(auto line: split(input, "\n")){
        auto edge = split(line, ")");
        graph[edge[0]].push_back(edge[1]);
        graph[edge[1]].push_back(edge[0]);        
    }
    long long res = 0;
    struct State { long long orbs; std::string name; };
    std::queue<State> queue;
    std::unordered_set<std::string> visited;
    queue.push({0, "YOU"});
    while(!queue.empty()){
        auto [orbs, name] = queue.front();
        queue.pop();
        if (visited.find(name) != visited.end()) continue;
        visited.insert(name);
        if(name == "SAN") {
            res = orbs - 2;
            break;
        }
        for(auto child: graph[name]){
            queue.push({orbs + 1, child});
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