pub fn part2(input: &Vec<usize>) -> usize {
    let mut total: usize = 0;

    for i in 0..input.len() {
        blink(input[i], 0, &mut total);
        println!("Handled {i}");
    }

    println!("Total: {}", total);

    total
}

fn blink(input: usize, iter: u8, mut total: &mut usize) {
    if iter == 75 {
        *total += 1;
        return;
    }

    if input == 0 {
        blink(1, iter + 1, &mut total)
    } else {
        let digits = (input as f64).log10().floor() as usize + 1;

        if digits % 2 == 0 {
            let half_digits = (digits + 1) / 2;
            let divisor = 10usize.pow((digits - half_digits) as u32);

            let left = input / divisor;     // Extract the left part
            let right = input % divisor;   // Extract the right part

            blink(left, iter + 1, &mut total);
            blink(right, iter + 1, &mut total);
        } else {
            blink(input * 2024, iter + 1, &mut total)
        }
    }
}