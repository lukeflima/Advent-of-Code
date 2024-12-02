def get_reports(input):
    return [list(map(int, i.split())) for i in input.split("\n")]

def part1(input):
    
    reports = get_reports(input)
    
    safe = [False] * len(reports)
    for i, report in enumerate(reports):
        all_increasing = True
        all_decreasing = True
        big_spike = False
        for level_l, level_r in zip(report[:-1], report[1:]):
            d = abs(level_l - level_r)
            if not (d >= 1 and d <= 3):
                big_spike = True
                break
            if level_l >= level_r:
                all_decreasing = False
            if level_l <= level_r:
                all_increasing = False

        if not big_spike and (all_decreasing or all_increasing):
            safe[i] = True
            
    print("Level 1:", sum(safe))
    return 0


def part2(input):
    reports = get_reports(input)

    def get_report_criteria(report: list, skip = None):
        if skip is not None:
            report = report[:]
            del report[skip]
        all_increasing = True
        all_decreasing = True
        big_spike = False
        for level_l, level_r in zip(report[:-1], report[1:]):
            d = abs(level_l - level_r)
            if not (d >= 1 and d <= 3):
                big_spike = True
                break
            if level_l >= level_r:
                all_decreasing = False
            if level_l <= level_r:
                all_increasing = False
        
        return big_spike, all_decreasing, all_increasing
    
    def is_safe(big_spike, all_decreasing, all_increasing):
        return not big_spike and (all_decreasing or all_increasing)
    
    safe = [False] * len(reports)
    for i, report in enumerate(reports):
        if is_safe(*get_report_criteria(report)):
            safe[i] = True
        else:
            for j in range(len(report)):
                if is_safe(*get_report_criteria(report, skip=j)):
                    safe[i] = True
                    break
                    
    print("Level 2:", sum(safe))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())