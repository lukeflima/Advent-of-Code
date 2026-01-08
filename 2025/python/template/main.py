import argparse
import os
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv() 


def main():
    parser = argparse.ArgumentParser(
                    prog='Create day template',
                    description='Creates template for given day of Advent of Code.',)
    parser.add_argument('day')

    args = parser.parse_args()

    day_str = args.day
    if not day_str.isdigit():
        parser.print_usage()
        print("ERROR: day is not a number.")
        return 1
    
    day = int(day_str) 
    day_folder = f"day{day:02}"

    Path(day_folder).mkdir(exist_ok=True)
    with open(Path(Path(__file__).resolve().parent, "template", "main.py")) as template, \
         open(Path(day_folder, "main.py"), "w") as newfile:
        newfile.write(template.read())

    Path(day_folder, "sample.txt").touch() 

    input_path = Path(day_folder, "input.txt")
    r = requests.get(f"https://adventofcode.com/2025/day/{day}/input", cookies={"session": os.getenv("SESSION_ID")})
    if r.status_code == 200:
        with open(input_path, "w") as input:
            input.write(r.text)
            print(f"{len(r.text)} bytes")
    else:
        print(f"Failed to fetch input: {r.status_code}")
        input_path.touch()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())