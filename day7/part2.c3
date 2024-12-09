import std::io;
import std::collections;

enum Operator {
    ADD,
    MULT,
    CONCAT
}

// 0b00 = ADD, 0b01 = MULTIPLY, 0b10 = CONCAT
def OperatorMatrix = List(<List(<char>)>);

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
    // it doesn't run out of ram so it's probably fine ¯\_(ツ)_/¯

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

    int possibilities = (int)$$pow_int((float)3, operator_count);

    for (int i = 0; i < possibilities; i++) {
        List(<char>) operator;
        operator.new_init();
        int temp = i;

        for (int j = 0; j < operator_count; j++) {
            int o = (i / (int)$$pow((float)3, (float)operator_count - (float)j - 1)) % 3;

            operator.push((char)o);
        }

        double result = apply_operators(operator, operator_count, values);
        if (result == total) {
            operator.free();
            io::print("true: ");
            io::printn(*line);
            return total;
        }

        operator.free();
    }

    return 0;
}

fn double apply_operators(List(<char>) operator, int operator_count, String[] raw_values) {
    // Parse the values
    List(<double>) values;
    values.new_init();
    defer values.free();

    foreach (&raw_value : raw_values) {
        values.push(raw_value.to_int())!!;
    }

    // Apply the operators
    foreach (&o : operator) {
        if (*o == (char)1) {
            // multiplication
            double result = values.pop_first()!! * values.pop_first()!!;
            values.push_front(result);
        } else if (*o == (char)0) {
            // addition
            double result = values.pop_first()!! + values.pop_first()!!;
            values.push_front(result);
        } else {
            // concat
            double num1 = values.pop_first()!!;
            double num2 = values.pop_first()!!;

            double digits = $$ceil($$log10(num2));

            // log10(1) is 0, but we need the amount of digits so it's overridden to 1.
            if (num2 == 1) {
                digits = 1;
            }

            double result = num1 * $$pow((double)10, digits) + num2;

            values.push_front(result);
        }
    }

    return values[0];
}

fn void main()
{
    String input = read_input();

    String[] lines = input.tsplit("\n");
    double calibration_result = 0;
    int line_count = 1;
    foreach (&line : lines) {
        double result = handle_line(line);
        calibration_result += result;
        line_count++;
    }

    io::printfn("Calibration result: %s", calibration_result);
}