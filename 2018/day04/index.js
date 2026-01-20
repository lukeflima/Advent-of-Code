const { time } = require('node:console');
const fs = require('node:fs');

function part1(input) {
    const logs = input.split("\n").map(line => {
        let [timestamp, event] = line.split("] ")
        timestamp = timestamp.slice(1);
        timestamp = new Date(timestamp);
        return [timestamp, event];
    });
    logs.sort((a, b) => a[0] - b[0]);

    const guards = {};
    let currentGuard = null;
    let sleepStart = null;
    for(const [timestamp, event] of logs) {
        if(event.startsWith("Guard")) {
            const guardId = event.split(" ")[1].slice(1);
            currentGuard = guardId;
            if(!(guardId in guards)) {
                guards[guardId] = Array(60).fill(0);
            }
        } else if(event === "falls asleep") {
            sleepStart = timestamp.getMinutes();
        } else if(event === "wakes up") {
            const sleepEnd = timestamp.getMinutes();
            for(let m = sleepStart; m < sleepEnd; m++) {
                guards[currentGuard][m]++;
            }
        }
    }

    let maxSleep = 0;
    let sleepiestGuard = null;
    for(const guardId in guards) {
        const totalSleep = guards[guardId].reduce((a, b) => a + b, 0);
        if(totalSleep > maxSleep) {
            maxSleep = totalSleep;
            sleepiestGuard = guardId;
        }
    }

    const sleepMinutes = guards[sleepiestGuard];
    let maxMinuteSleep = 0;
    let sleepiestMinute = 0;
    for(let m = 0; m < 60; m++) {
        if(sleepMinutes[m] > maxMinuteSleep) {
            maxMinuteSleep = sleepMinutes[m];
            sleepiestMinute = m;
        }
    }


    return parseInt(sleepiestGuard) * sleepiestMinute;
}

function part2(input) {
    const logs = input.split("\n").map(line => {
        let [timestamp, event] = line.split("] ")
        timestamp = timestamp.slice(1);
        timestamp = new Date(timestamp);
        return [timestamp, event];
    });
    logs.sort((a, b) => a[0] - b[0]);

    const guards = {};
    let currentGuard = null;
    let sleepStart = null;
    for(const [timestamp, event] of logs) {
        if(event.startsWith("Guard")) {
            const guardId = event.split(" ")[1].slice(1);
            currentGuard = guardId;
            if(!(guardId in guards)) {
                guards[guardId] = Array(60).fill(0);
            }
        } else if(event === "falls asleep") {
            sleepStart = timestamp.getMinutes();
        } else if(event === "wakes up") {
            const sleepEnd = timestamp.getMinutes();
            for(let m = sleepStart; m < sleepEnd; m++) {
                guards[currentGuard][m]++;
            }
        }
    }

    let maxMinuteSleep = 0;
    let sleepiestGuard = null;
    let sleepiestMinute = 0;
    for(const guardId in guards) {
        const sleepMinutes = guards[guardId];
        for(let m = 0; m < 60; m++) {
            if(sleepMinutes[m] > maxMinuteSleep) {
                maxMinuteSleep = sleepMinutes[m];
                sleepiestGuard = guardId;
                sleepiestMinute = m;
            }
        }
    }

    return parseInt(sleepiestGuard) * sleepiestMinute;
}

function main() {
    if(process.argv.length != 3) {
        console.log("node index.js <text input>")
        process.exit(1);
    }
    
    const input = fs.readFileSync(process.argv[2], "utf8").trim();

    console.log(`Part 1: ${part1(input)}`);
    console.log(`Part 2: ${part2(input)}`);
}   

main();