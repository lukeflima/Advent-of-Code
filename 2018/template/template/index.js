const fs = require('node:fs');

function part1(input) {
    return 0;
}

function part2(input) {
    return 0;
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