import argparse
from pathlib import Path


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
    with open(Path(Path(__file__).parent, "template", "main.py")) as template, \
         open(Path(day_folder, "main.py"), "w") as newfile:
        newfile.write(template.read())
    Path(day_folder, "inputtest.txt").touch()
    Path(day_folder, "input.txt").touch()

    return 0

if __name__ == "__main__":
    raise SystemExit(main())