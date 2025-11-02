#include <algorithm>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <unordered_map>
#include <ranges>
#include <format>
#include <vector>
#include <cmath>
#include <numeric>
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


struct Point {
    int x;
    int y;
    inline bool operator==(const Point &p) const {
        return x == p.x && y == p.y;
    }
    inline Point operator-(const Point &p) const {
        return {x - p.x, y - p.y};
    }
    double length() {
        return std::abs(std::sqrt((double) (x * x + y * y) ));
    }
    double angle() {
        return std::atan2(y, x) + std::numbers::pi;
    }
};

template <>
struct std::formatter<Point> : std::formatter<std::string> {
    auto format(const Point& p, std::format_context& ctx) const {
        return formatter<std::string>::format("Point{.x=" + std::to_string(p.x) + ", .y=" + std::to_string(p.y) + "}", ctx);
    }
};

Point normalize(const Point p) {
    if (p == Point{0, 0}) return p;
    int gcd = std::gcd(p.x, p.y);
    if(gcd == 0) {
      if (p.x == 0) return {0, p.y < 0 ? -1 : 1};
      return {p.x < 0 ? -1 : 1, 0};
    }
    return {p.x/gcd, p.y/gcd};
}



struct Point_Hash {
    inline std::size_t operator()(const Point &p) const {
        return p.x*100+p.y;
    }
};


std::string part1(const std::string_view input) {
    auto input_lines = split(input, "\n");
    auto width = input_lines.size();
    auto height = input_lines[0].size();

    std::vector<Point> asteroids;
    for (size_t i = 0; i < width; i++) {
        for (size_t j = 0; j < height; j++) {
            if (input_lines[i][j] == '#') asteroids.emplace_back((int) i, (int)j);
        }
    }

    size_t best_location = 0;
    for (auto asteroid = asteroids.begin(); asteroid != asteroids.end(); ++asteroid) {
        std::unordered_map<Point, Point, Point_Hash> lines;
        for (auto neighbour = asteroids.begin(); neighbour != asteroids.end(); ++neighbour) {
            if (*asteroid == *neighbour) continue;
            auto distance = *neighbour - *asteroid;
            auto line = normalize(distance);
            if (lines.contains(line)) {
                auto distance2 = lines[line] - *asteroid ;
                if (distance.x < distance2.x || distance.y < distance2.y) lines.insert_or_assign(line, *neighbour);
            }
            else lines.insert({line, *neighbour});
        }
        best_location = std::max(best_location, lines.size());
    }
    return std::to_string(best_location);
}

std::string part2(const std::string_view input) {
    auto input_lines = split(input, "\n");
    auto width = input_lines.size();
    auto height = input_lines[0].size();

    Point best_location = {-1, -1};
    std::vector<Point> asteroids;
    for (size_t i = 0; i < width; i++) {
        for (size_t j = 0; j < height; j++) {
            if (input_lines[i][j] == '#') asteroids.emplace_back((int) i, (int)j);
            if (input_lines[i][j] == 'X') best_location = {(int) i, (int)j};
        }
    }

    if(best_location == Point{-1, -1}) {
        size_t best_location_score = 0;
        for (auto asteroid = asteroids.begin(); asteroid != asteroids.end(); ++asteroid) {
            std::unordered_map<Point, Point, Point_Hash> lines;
            for (auto neighbour = asteroids.begin(); neighbour != asteroids.end(); ++neighbour) {
                if (*asteroid == *neighbour) continue;
                auto distance = *neighbour - *asteroid;
                auto line = normalize(distance);
                if (lines.contains(line)) {
                    auto distance2 = lines[line] - *asteroid ;
                    if (distance.x < distance2.x || distance.y < distance2.y) lines.insert_or_assign(line, *neighbour);
                }
                else lines.insert({line, *neighbour});
            }
            if (lines.size() > best_location_score) {
                best_location_score = lines.size();
                best_location = *asteroid;
            }
        }
    }

    struct Target {
        Point p;
        double distance;
        bool intact;
    };

    std::unordered_map<double, std::vector<Target>> neighbours(asteroids.size() - 1);

     for(auto neighbour = asteroids.begin(); neighbour != asteroids.end(); ++neighbour) {
        if (best_location == *neighbour) continue;
        auto distance = best_location - *neighbour;
        neighbours[normalize(distance).angle()].push_back({*neighbour, distance.length(), true});
    }

    std::vector<double> angles;
    for(auto it = neighbours.begin(); it != neighbours.end(); ++it) {
        angles.push_back(it->first);
    }
    std::ranges::sort(angles);

    double laser_default_angle = (Point{1, 0}).angle();
    size_t laser_angle_index = -1;
    for(size_t i = 0; i < angles.size(); i++) {
        if(angles[i] == laser_default_angle) {
            laser_angle_index = i;
            break;
        }
    }

    size_t destroyed = 0;
    Point vaporized_200;
    while(1) {
        auto laser_angle = angles[laser_angle_index];
        auto& full_targets = neighbours[laser_angle];
        auto targets = std::views::filter(full_targets, &Target::intact);
        auto target = std::ranges::min(targets, {}, &Target::distance);
        destroyed += 1;
        if(destroyed == 200) {
            vaporized_200 = target.p;
            break;
        }
        auto destroy_target = std::ranges::find_if(full_targets, [&target](auto t){ return t.distance == target.distance; });
        destroy_target->intact = false;

        if(laser_angle_index == 0) laser_angle_index = angles.size() - 1;
        else laser_angle_index -= 1;
    }

    auto res = vaporized_200.y * 100 + vaporized_200.x;
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
