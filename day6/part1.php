<?php
    // global variables are awesome actually
    global $character_turn_map,
           $character_direction_offset,
           $input_matrix,
           $position,
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

        if ($char_at_pos == '#') {
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
?>