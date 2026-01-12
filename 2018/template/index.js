const fs = require('node:fs');

async function main() {
    if(process.argv.length != 3) {
        console.log("node index.js <text input>")
        process.exit(1);
    }

    require('dotenv').config();

    const day = parseInt(process.argv[2]);
    const day_str = day.toString().padStart(2, '0');

    fs.cpSync("template", `../day${day_str}`, {recursive: true});

    const res = await fetch(`https://adventofcode.com/2018/day/${day}/input`, {
        headers: {
            cookie: `session=${process.env["SESSION_ID"]}`
        }
    });
    fs.writeFileSync(`../day${day_str}/input.txt`, await res.text());
}

main();

