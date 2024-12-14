use std::collections::HashMap;

pub fn part2(input: &Vec<usize>) -> usize {
    let mut total: usize = 0;
    // <(input, itr),stones>
    let mut memo: HashMap<(usize, u8), usize> = HashMap::new();

    for i in 0..input.len() {
        blink(input[i], 0, &mut total, &mut memo);
        println!("Handled {i}");
    }

    total
}

fn blink(input: usize, iter: u8, mut total: &mut usize, mut memo: &mut HashMap<(usize, u8), usize>) {
    if iter == 75 {
        *total += 1;
        return;
    }

    if memo.contains_key(&(input, iter)) {
        *total += memo.get(&(input, iter)).unwrap();
        return;
    }

    let total_at_start = total.clone();

    if input == 0 {
        blink(1, iter + 1, &mut total, &mut memo)
    } else {
        let digits = (input as f64).log10().floor() as usize + 1;

        if digits % 2 == 0 {
            let half_digits = (digits + 1) / 2;
            let divisor = 10usize.pow((digits - half_digits) as u32);

            let left = input / divisor;     // Extract the left part
            let right = input % divisor;   // Extract the right part

            blink(left, iter + 1, &mut total, &mut memo);
            blink(right, iter + 1, &mut total, &mut memo);
        } else {
            blink(input * 2024, iter + 1, &mut total, &mut memo)
        }
    }

    let count = *total - total_at_start;
    memo.insert((input, iter), count);
}