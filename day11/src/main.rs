use std::fs::File;
use std::io::Read;
use std::path::Path;

// 24 for part 1, 74 for part 2
const NUMBER_OF_ADDITIONAL_ITERATIONS: u8 = 74;

// This puzzle sucks. RAM should not be the limiting factor.

fn main() {
    let path = Path::new("./input.txt");
    let mut file = File::open(path).unwrap();
    let mut input = String::new();
    file.read_to_string(&mut input).unwrap();

    let input = input
        .trim()
        .split(" ")
        .into_iter()
        .map(|x| x.parse::<usize>())
        .collect::<Result<Vec<usize>, _>>()
        .unwrap();

    println!("{:?}", input);

    let mut value = blink(&input);

    // did it once already, x - 1 more times to go
    for iteration in 0..NUMBER_OF_ADDITIONAL_ITERATIONS {
        println!("Iteration: {}/{}", iteration + 1, NUMBER_OF_ADDITIONAL_ITERATIONS);
        value = blink(&value);
    }

    println!("Stones: {}", value.len());
}

fn blink(input: &Vec<usize>) -> Vec<usize> {
    let mut out = vec![];

    for i in 0..input.len() {
        let v = input[i];

        if v == 0 {
            out.push(1);
        } else  {
            if v == 0 {
                out.push(0);
                out.push(0);
            }

            let digits = (v as f64).log10().floor() as usize + 1;

            if digits % 2 == 0 {
                let half_digits = (digits + 1) / 2;
                let divisor = 10usize.pow((digits - half_digits) as u32);

                let left = v / divisor;     // Extract the left part
                let right = v % divisor;   // Extract the right part

                out.push(left);
                out.push(right);
            } else {
                out.push(v * 2024);
            }
        }
    }

    out
}