<?php

// With the PHP lessons I have learnt from part 1 I rewrote everything in a v2 for part 2
// This implementation is functional but very unoptimized. It checks every 26k spots for a
// loop causing obstruction spot. This can be improved with multi-threading and evaluating
// the guard walk first, getting the spots where obstructions are even useful and then only
// checking those. This would make the possible spots go from 26k to about 5k. Another
// optimization would be to start the loop check runs from the spot before the obstruction,
// saves a lot of useless walking.

const direction_map = array('^' => [-1, 0], '>' => [0, 1], 'v' => [1, 0], '<' => [0, -1]);
const rotation_map = array('^' => '>', '>' => 'v', 'v' => '<', '<' => '^');
const directions = array('^', '>', 'v', '<');
define("grid", load_grid());
define("start_position", get_character_position());

log_grid(grid);

$obstruction_count = 0;
for ($y = 0; $y < count(grid); $y++) {
    for ($x = 0; $x < count(grid[0]); $x++) {
        $cell = grid[$y][$x];

        if ($cell == '.' && ($y != start_position[0] || $x != start_position[1])) {
            $grid = grid;
            $grid[$y][$x] = 'O';

            if (move_guard($grid, start_position[0], start_position[1], start_position[2])) {
                $obstruction_count++;
                echo $obstruction_count . "\n";
            }
        }

        echo "($x,$y): $obstruction_count\n";
    }
}

echo "$obstruction_count";

function move_guard($grid, $y, $x, $r) {
    $visited = array();

    while (true) {
        $vector = direction_map[$r];
        $ny = $y + $vector[0];
        $nx = $x + $vector[1];

        if ($nx < 0 || $ny < 0 || $ny >= count($grid) || $nx >= count($grid[0])) {
            break;
        }

        $cell = $grid[$ny][$nx];
        $state = "$ny.$nx.$r";

        if (in_array($state, $visited)) {
            // this appears to loop
            return true;
        }

        $visited[] = $state;

        if ($cell != "#" && $cell != "O") {
            $grid[$y][$x] = 'X';
            $grid[$ny][$nx] = $r;

            $y = $ny;
            $x = $nx;
        } else {
            $r = rotation_map[$r];
        }
    }

    return false;
}

function get_character_position() {
    for ($y = 0; $y < count(grid); $y++) {
        for ($x = 0; $x < count(grid[0]); $x++) {
            if (in_array(grid[$y][$x], directions)) {
                return [$y, $x, grid[$y][$x]];
            }
        }
    }

    return [0, 0, '^'];
}

function load_grid() {
    $file = file_get_contents("input.txt");
    $lines = explode("\n", $file);
    $grid = array();

    foreach ($lines as $line) {
        $line = trim($line);
        $grid[] = str_split($line);
    }

    return $grid;
}

function log_grid($grid) {
    foreach ($grid as $line) {
        echo implode("", $line) . "\n";
    }
}
?>