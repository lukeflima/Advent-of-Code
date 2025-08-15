#include <cctype>
#include <cstddef>
#include <ostream>
#include <print>
#include <cpr/cpr.h>
#include <cstdlib>
#include <string>
#include <string_view>
#include <fstream>  
#include <filesystem>
#include <stdlib.h>
#include <vector>

namespace fs = std::filesystem;


void download_input(int day, std::string_view folder_path) {
    const char* session_id = std::getenv("SESSION_ID");
    if (session_id == nullptr) return;

    const auto input_url = std::format("https://adventofcode.com/2019/day/{}/input", day);
    auto r = cpr::Get(cpr::Url{input_url}, cpr::Cookie("session", session_id));

    const auto file_path = fs::path(folder_path) / "input.txt";
    std::ofstream input_file(file_path);
    input_file << r.text;
    std::println("{} bytes", r.text.length());
    input_file.close();
}

std::string remove_quotes(std::string_view s) {
    if (s.size() < 2) return std::string(s);
    if(!(s[0] == '\''  && s[s.size()-1] == '\'') && !(s[0] == '"'  && s[s.size()-1] == '"')) return std::string(s);
    return std::string(s.substr(1, s.size() - 2));
}

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

void dotenv_init(std::string dotenv_filepath = ".env") {
    std::ifstream dotenv_file(dotenv_filepath);
    for(std::string line; getline( dotenv_file, line ); ){
        auto parts = split(line, "=");
        if(parts.size() != 2) continue;
        auto name = strip(parts[0]);
        auto value = remove_quotes(strip(parts[1]));
        setenv(name.c_str(), value.c_str(), 1);
    }
    dotenv_file.close();
}

int main(int argc, char **argv) {
    
    if(argc != 2) {
        std::print("Usage: {} <day>\n", argv[0]);
        return -1;
    }
    
    dotenv_init();

    const auto day = std::atoi(argv[1]);
    const auto day_path = std::format("day{:02d}", day);

    fs::copy("template/template", day_path, fs::copy_options::recursive);
    fs::create_directories(fs::path(day_path) / "build");
    download_input(day, day_path);
    return 0;
}