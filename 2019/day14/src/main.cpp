#include <cstddef>
#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <unordered_map>
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
        prev = i + delimiter.length();
    }
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
}

struct Ingredient {
    std::string name;
    size_t quantity;
};

struct Operation {
    Ingredient result;
    std::vector<Ingredient> ingredients;
};

std::string part1(const std::string_view input) {
    std::unordered_map<std::string, Operation> data;
    auto lines = split(input, "\n");
    for(auto line : lines) {
        auto parts = split(line, " => ");
        auto ingredients_str = split(parts[0], ", ");
        std::vector<Ingredient> ingredients;
        for(auto ingredient_str : ingredients_str) {
            auto ingredient_parts = split(ingredient_str, " ");
            ingredients.push_back(Ingredient{ingredient_parts[1], std::stoul(ingredient_parts[0])});
        }
        auto result_parts = split(parts[1], " ");
        Ingredient result{result_parts[1], std::stoul(result_parts[0])};
        data[result.name] = Operation{result, ingredients};
    }

    auto needed = std::unordered_map<std::string, size_t>{{"FUEL", 1}};
    auto surplus = std::unordered_map<std::string, size_t>{};
    while(true) {
        bool done = true;
        for(const auto& [name, quantity_needed] : needed) {
            if(name == "ORE" || quantity_needed == 0) continue;
            done = false;
            const auto& operation = data[name];
            size_t quantity_available = surplus[name];
            size_t quantity_to_produce = 0;
            if(quantity_available >= quantity_needed) {
                surplus[name] -= quantity_needed;
                needed[name] = 0;
                continue;
            } else {
                quantity_to_produce = quantity_needed - quantity_available;
                surplus[name] = 0;
            }
            size_t times = (quantity_to_produce + operation.result.quantity - 1) / operation.result.quantity;
            surplus[name] += times * operation.result.quantity - quantity_to_produce;
            needed[name] = 0;
            for(const auto& ingredient : operation.ingredients) {
                needed[ingredient.name] += times * ingredient.quantity;
            }
            break; 
        }
        if(done) break;
    }

    return std::to_string(needed["ORE"]);
}

std::string part2(const std::string_view input) {
    std::unordered_map<std::string, Operation> data;
    auto lines = split(input, "\n");
    for(auto line : lines) {
        auto parts = split(line, " => ");
        auto ingredients_str = split(parts[0], ", ");
        std::vector<Ingredient> ingredients;
        for(auto ingredient_str : ingredients_str) {
            auto ingredient_parts = split(ingredient_str, " ");
            ingredients.push_back(Ingredient{ingredient_parts[1], std::stoul(ingredient_parts[0])});
        }
        auto result_parts = split(parts[1], " ");
        Ingredient result{result_parts[1], std::stoul(result_parts[0])};
        data[result.name] = Operation{result, ingredients};
    }

    auto needed = std::unordered_map<std::string, size_t>{{"FUEL", 1}};
    auto surplus = std::unordered_map<std::string, size_t>{};
    while(true) {
        bool done = true;
        for(const auto& [name, quantity_needed] : needed) {
            if(name == "ORE" || quantity_needed == 0) continue;
            done = false;
            const auto& operation = data[name];
            size_t quantity_available = surplus[name];
            size_t quantity_to_produce = 0;
            if(quantity_available >= quantity_needed) {
                surplus[name] -= quantity_needed;
                needed[name] = 0;
                continue;
            } else {
                quantity_to_produce = quantity_needed - quantity_available;
                surplus[name] = 0;
            }
            size_t times = (quantity_to_produce + operation.result.quantity - 1) / operation.result.quantity;
            surplus[name] += times * operation.result.quantity - quantity_to_produce;
            needed[name] = 0;
            for(const auto& ingredient : operation.ingredients) {
                needed[ingredient.name] += times * ingredient.quantity;
            }
            break; 
        }
        if(done) break;
    }

    auto ore_for_one_fuel = needed["ORE"];
    size_t low = 1;
    size_t high = 1'000'000'000'000 / ore_for_one_fuel * 2;
    while(low < high) {
        size_t mid = (low + high + 1) / 2;
        needed = std::unordered_map<std::string, size_t>{{"FUEL", mid}};
        surplus = std::unordered_map<std::string, size_t>{};
        while(true) {
            bool done = true;
            for(const auto& [name, quantity_needed] : needed) {
                if(name == "ORE" || quantity_needed == 0) continue;
                done = false;
                const auto& operation = data[name];
                size_t quantity_available = surplus[name];
                size_t quantity_to_produce = 0;
                if(quantity_available >= quantity_needed) {
                    surplus[name] -= quantity_needed;
                    needed[name] = 0;
                    continue;
                } else {
                    quantity_to_produce = quantity_needed - quantity_available;
                    surplus[name] = 0;
                }
                size_t times = (quantity_to_produce + operation.result.quantity - 1) / operation.result.quantity;
                surplus[name] += times * operation.result.quantity - quantity_to_produce;
                needed[name] = 0;
                for(const auto& ingredient : operation.ingredients) {
                    needed[ingredient.name] += times * ingredient.quantity;
                }
                break; 
            }
            if(done) break;
        }
        if(needed["ORE"] <= 1'000'000'000'000) {
            low = mid;
        } else {
            high = mid - 1;
        }
    }
    return std::to_string(low);

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