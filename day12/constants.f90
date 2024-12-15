module constants
    use coords
    implicit none

    type(coordinate), parameter :: DIRECTIONS(4) = [ &
            ! once again some interesting syntax
            coordinate(-1, 0), &
                    coordinate(1, 0), &
                    coordinate(0, -1), &
                    coordinate(0, 1) &
            ]
end module constants