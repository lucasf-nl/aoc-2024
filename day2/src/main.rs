use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let file = File::open("./input.txt").expect("file not found");
    let reader = BufReader::new(file);
    let mut count: u16 = 0;

    for line in reader.lines() {
        match line {
            Ok(line) => {
                let segments = line.split(" ").collect::<Vec<&str>>();
                let segments = segments
                    .iter()
                    .map(|s| s.parse::<u8>().unwrap())
                    .collect::<Vec<u8>>();

                if check_report_safety(segments) {
                    count += 1;
                }
            },
            Err(err) => {
                panic!("Error reading line: {}", err);
            }
        }
    }

    println!("Safe reports: {}", count);
}

fn check_report_safety(numbers: Vec<u8>) -> bool {
    if numbers.len() == 0 || numbers[0] == numbers[1] {
        return false
    };

    let increasing = numbers[0] < numbers[1];
    let mut numbers = numbers.iter();
    let mut previous: &u8 = numbers.next().unwrap();

    for num in numbers {
        if previous == num {
            return false
        }

        if previous != num && (
            (previous >= num && increasing) ||
                (previous <= num && !increasing)
        ) {
            return false
        }

        let abs = previous.abs_diff(*num);
        if abs > 3 {
            return false
        }

        previous = num;
    }

    true
}