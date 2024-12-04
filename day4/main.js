// const input = `MMMSXXMASM
// MSAMXMSMSA
// AMXSXMAAMM
// MSAMASMSMX
// XMASAMXAMM
// XXAMMXXAMA
// SMSMSASXSS
// SAXAMASAAA
// MAMMMXMMMM
// MXMXAXMASX`

const fs = require("fs");

const input = fs.readFileSync("input.txt").toString();

let input_matrix = input.split("\n").map(v => v.split(""));
let xmas_count = 0;

for (let y = 0; y < input_matrix.length; y++) {
    for (let x = 0; x < input_matrix[0].length; x++) {
        let char = input_matrix[y][x]

        if (char === "X") {
            let possible_directions = get_directions(x, y, "M")

            for (let directioni = 0; directioni < possible_directions.length; directioni++) {
                let direction = possible_directions[directioni]
                let characters = ["X", "M"]

                // TODO: better variable name
                for (let extremification = 2; extremification <= 3; extremification++) {
                    let yaxis = input_matrix[y + (direction[1] * extremification)];
                    if (yaxis !== undefined) {
                        let char = yaxis[x + (direction[0] * extremification)]
                        if (char !== undefined) {
                            characters.push(char)
                        }
                    }
                }

                if (characters.join("") === "XMAS") {
                    xmas_count++
                }
            }
        }
    }
}

console.log("XMAS Count: " + xmas_count)

function get_directions(x, y, next) {
    let directions = [];

    return [
        // (x, y)
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, -1],
        // skip 0, 0
        [0, 1],
        [1, -1],
        [1, 0],
        [1, 1]
    ]
        .filter(v => input_matrix[y + v[1]] !== undefined && input_matrix[y + v[1]][x + v[0]] !== undefined)
        .map(v => [...v, input_matrix[y + v[1]][x + v[0]]])
        .filter(v => v[2] === next)
}
