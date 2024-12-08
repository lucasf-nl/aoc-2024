<?php
    // global variables are awesome actually
    global $character_turn_map,
           $character_direction_offset,
           $input_matrix,
           $position,
           $loop_obstruction_count,
           $input_matrix;

    // cute kaomoji, but with purpose.
    // This is not a fancy looping iterator because I do not get paid enough and this is not Rust.
    $character_turn_map = str_split("^>v<^");
    $character_direction_offset =
        array('^' => [0, -1], '>' => [1, 0], 'v' => [0, 1], '<' => [-1, 0]);

    $input = file_get_contents("input.txt");
    $input_matrix = [];
    // xyc
    $position = [];
    $loop_obstruction_count = 0;

    $input_exploded = explode("\n", $input);
    for ($y = 0; $y < count($input_exploded); $y++) {
        $column = $input_exploded[$y];
        $column_split = str_split($column);
        $column_matrix = [];

        for ($x = 0; $x < count($column_split); $x++) {
            $character = $column_split[$x];

            if (character_is_pointer($character)) {
                $position = [$x, $y, $character];
            }

            $column_matrix[] = $column_split[$x];
        }

        $input_matrix[] = $column_matrix;
    }

    $i = 0;

    while ($position[0] < (count($input_matrix[0]) - 1) && $position[0] >= 0 &&
    $position[1] < (count($input_matrix) - 1) && $position[1] >= 0) {
        $i++;
        if (check_obstruction()) {
            handle_character_turn();
        } else {
            // mark X
            $input_matrix[$position[1]][$position[0]] = "X";

            $offset = $character_direction_offset[$position[2]];

            $x = $position[0] + $offset[0];
            $y = $position[1] + $offset[1];

            // update char in matrix
            if ($y > 0 && $x > 0) {
                $input_matrix[$y][$x] = $position[2];
            }

            // move in pos
            $position[0] = $x;
            $position[1] = $y;

            evaluate_loopability($input_matrix, $position);
        }
    }

    log_matrix();
    if ($position[0] > 0 && $position[1] > 0) {
        // The ending pos isn't an X but still counts so we add 1
        echo "Count X: " . (count_char_in_matrix($input_matrix, "X") + 1) . "\n";
    } else {
        // Ending pos isn't in matrix, do not add 1
        echo "Count X: " . count_char_in_matrix($input_matrix, "X") . "\n";
    }
    echo "Found " . $loop_obstruction_count . " possible loop-causing obstructions";

    function log_matrix() {
        global $input_matrix;
        foreach ($input_matrix as $y) {
            echo implode("", $y) . "\n";
        }
    }

    function check_obstruction() {
        global $position, $character_direction_offset, $input_matrix;
        $offset = $character_direction_offset[$position[2]];

        $x = $position[0] + $offset[0];
        $y = $position[1] + $offset[1];

        if ($x == -1 || $y == -1) {
            return false;
        }

        $char_at_pos = $input_matrix[$y][$x];

        if ($char_at_pos == '#' || $char_at_pos == 'O') {
            return true;
        }

        return false;
    }

    function handle_character_turn() {
        global $character_turn_map, $position;

        $current_index = get_index_of_item_in_array($character_turn_map, $position[2]);
        $new_character = $character_turn_map[$current_index + 1];
        $position[2] = $new_character;
    }

    function get_index_of_item_in_array($array, $item) {
        for ($i = 0; $i < count($array); $i++) {
            if ($array[$i] == $item) {
                return $i;
            }
        }

        return -1;
    }

    function character_is_pointer($character) {
        global $character_turn_map;
        return get_index_of_item_in_array($character_turn_map, $character) != -1;
    }

    function count_char_in_matrix($matrix, $character) {
        $i = 0;

        for ($y = 0; $y < count($matrix); $y++) {
            for ($x = 0; $x < count($matrix[$y]); $x++) {
                if ($matrix[$y][$x] == $character) {
                    $i++;
                }
            }
        }

        return $i;
    }

    function walk_path($matrix, $character) {

    }

    // Turn right by placing obstruction and go until you find a path that has been walked and has an obstruction
    function evaluate_loopability($matrix, $position)
    {
        global $character_turn_map, $character_direction_offset, $loop_obstruction_count, $input_matrix;

        $going_forwards_offset = $character_direction_offset[$position[2]];
        $current_rotation = get_index_of_item_in_array($character_turn_map, $position[2]);
        $rotation = $current_rotation + 1;
        $rotated_character = $character_turn_map[$rotation];
        $offset = $character_direction_offset[$rotated_character];
        $rotated_rotation = get_index_of_item_in_array($character_turn_map, $rotated_character);
        $another_rotation = $rotated_rotation + 1;
        $another_rotated_character = $character_turn_map[$another_rotation];
        $another_rotated_offset = $character_direction_offset[$another_rotated_character];

        $x = $position[0];
        $y = $position[1];

        while ($x >= 0 && $y >= 0 && $y < count($matrix) && $x < count($matrix[0])) {
            $offset_coords = apply_offset($x, $y, $offset);
            $x = $offset_coords[0];
            $y = $offset_coords[1];

            if ($x == -1 || $y == -1 || $x == count($matrix[0]) || $y == count($matrix)) {
                break;
            }

            if (
                // there's something to turn on again
                get_char_in_front_of_character($x, $y, $matrix, $offset) == '#' &&
                // this has been walked before
                $matrix[$y][$x] == "X"// &&
//                $matrix[$y + $another_rotated_offset[1]][$x + $another_rotated_offset[0]] == "X"
                //$another_rotated_offset
            ) {
                // yaaay, this might be a viable path

                // temporary set the O so that debugging gets easier (breakpoint on echo)
                $old_val = $input_matrix[$position[1] + $going_forwards_offset[1]][$position[0] + $going_forwards_offset[0]];
                $input_matrix[$position[1] + $going_forwards_offset[1]][$position[0] + $going_forwards_offset[0]] = "O";
                $old_val_pos = $input_matrix[$y][$x];
                $input_matrix[$y][$x] = $rotated_character;

                echo "Found possible loop obstruction at (" . $position[0] . ", " . $position[1] . ")";
                $loop_obstruction_count++;
                $input_matrix[$position[1] + $going_forwards_offset[1]][$position[0] + $going_forwards_offset[0]] = $old_val;
                $input_matrix[$y][$x] = $old_val_pos;

                break;
            }

//            if (get_char_in_front_of_character($x, $y, $matrix, $offset) == '#') {
//                // still something there, bye
//                break;
//            }

            if ($matrix[$y][$x] == "#") {
                break;
            }
        }
    }

    function apply_offset($x, $y, $offset) {
        return array($x + $offset[0], $y + $offset[1]);
    }

    function get_char_in_front_of_character($x, $y, $matrix, $offset) {
        $x = $x + $offset[0];
        $y = $y + $offset[1];

        if ($x < 0 || $x >= count($matrix[0]) || $y < 0 || $y >= count($matrix)) {
            return ".";
        }

        return $matrix[$y][$x];
    }
?>