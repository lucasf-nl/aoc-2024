import std::io;
import std::collections;

// 0b0 = ADD, 0b1 = MULTIPLY
def OperatorMatrix = List(<double>);

fn String read_input() {
    String filename = "input.txt";
    usz filesize = file::get_size(filename)!!;
    File file = file::open(filename, "r")!!;

    usz read = 0;
    char[25] buffer = {};
    List(<char>) char_result;
    char_result.new_init();

    while (read < filesize) {
        if ((filesize - read) >= 25) {
            // update read progress
            read = read + 25;

            // read into buffer and add onto char_result
            file.read(&buffer)!!;
            char_result.add_array(&buffer);
        } else {
            usz difference = filesize - read;
            read = filesize;

            file.read(&buffer)!!;
            char_result.add_array(buffer[0 .. difference - 1]);
        }
    }

    char[] array = char_result.array_view();

    // is there debris to clean up or does c3 do that automatically?

    return (String)array;
}

fn double handle_line(String* line) {
    String[] segments = line.tsplit(": ");
    double total = segments[0].to_double()!!;

    String[] values = segments[1].tsplit(" ");
    int operator_count = 0;

    foreach (&value : values) {
        operator_count++;
    }

    // The amount of operators needed is nv-1
    operator_count--;

    int possibilities = (int)$$pow_int((float)2, operator_count);

    for (int i = 0; i < possibilities; i++) {
        double result = apply_operators(i, operator_count, values);
        if (result == total) {
            return total;
        }
    }

    return 0;
}

fn double apply_operators(int operators, int operator_count, String[] raw_values) {
    int least_significant = 0b0000_0000_0000_0001;

    // first we'll just turn the operators upside down and in an array
    List(<bool>) ud_operators;
    ud_operators.new_init();

    for (int i = 0; i < operator_count; i++) {
        bool is_multiplication = ((operators >> i) & 1) == 1;
        ud_operators.push(is_multiplication);
    }

    // Parse the values
    List(<double>) values;
    values.new_init();

    foreach (&raw_value : raw_values) {
        values.push(raw_value.to_int())!!;
    }

    // Apply the operators
    for (int i = 0; i < operator_count; i++) {
        if (ud_operators[i] == true) {
            // multiplication
            double result = values.pop_first()!! * values.pop_first()!!;
            values.push_front(result);
        } else {
            // addition
            double result = values.pop_first()!! + values.pop_first()!!;
            values.push_front(result);
        }
    }

    return values[0];
}

fn OperatorMatrix available_options(double count) {
    // Should give count^2 results all containing count operators, in total count*count^2.
    // This is done using binary logic.

    OperatorMatrix matrix;
    matrix.new_init();

    for (double i = 0; i < count*2; i++) {
        matrix.push(i);
    }

    return matrix;
}

fn void main()
{
    String input = read_input();
    io::printfn("%s", input);

    String[] lines = input.tsplit("\n");
    double calibration_result = 0;
    foreach (&line : lines) {
        calibration_result += handle_line(line);
    }

    io::printfn("Calibration result: %s", calibration_result);
}