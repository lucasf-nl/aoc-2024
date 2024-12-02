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

                if check_report_safety(segments, true) {
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

fn is_increasing(numbers: &Vec<u8>) -> bool {
    let t = numbers
        .windows(2).map(|w| w[0] <= w[1])
        .filter(|b| *b)
        .collect::<Vec<bool>>();

    t.len() > (numbers.len() / 2)
}

fn check_report_safety(numbers: Vec<u8>, first: bool) -> bool {
    if numbers.len() == 0 {
        return false
    };

    let increasing = is_increasing(&numbers);
    let original_numbers = numbers.clone();
    let mut numbers = numbers.iter();
    let mut previous: &u8 = numbers.next().unwrap();

    for (i, num) in numbers.enumerate() {
        let abs = previous.abs_diff(*num);
        if abs > 3 ||
            abs == 0 ||
            (previous > num && increasing) ||
            (previous < num && !increasing) {

            let mut first_index_removed = original_numbers.clone();
            first_index_removed.remove(i);
            let mut second_index_removed = original_numbers.clone();
            second_index_removed.remove(i + 1);

            return first && (check_report_safety(first_index_removed, false) ||
                check_report_safety(second_index_removed, false));
        }

        previous = num;
    }

    true
}

#[cfg(test)]
mod tests {
    use crate::check_report_safety;

    #[test]
    fn report_safety() {
        assert_eq!(true, check_report_safety(vec![7, 6, 4, 2, 1], true));
        assert_eq!(false, check_report_safety(vec![1, 2, 7, 8, 9], true));
        assert_eq!(false, check_report_safety(vec![9, 7, 6, 2, 1], true));
        assert_eq!(true, check_report_safety(vec![1, 3, 2, 4, 5], true));
        assert_eq!(true, check_report_safety(vec![8, 6, 4, 4, 1], true));
        assert_eq!(true, check_report_safety(vec![1, 3, 6, 7, 9], true));

        assert_eq!(true, check_report_safety(vec![2, 3, 6, 9, 8], true));
        assert_eq!(true, check_report_safety(vec![3, 2, 6, 8, 9], true));
    }
}