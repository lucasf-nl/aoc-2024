module stuff
    use constants
    implicit none
contains
    subroutine add_coordinate(visited, num_visited, x, y)
        use iso_fortran_env, only: error_unit
        implicit none
        type(coordinate), allocatable, intent(inout) :: visited(:)
        integer, intent(inout) :: num_visited
        integer, intent(in) :: x, y
        type(coordinate), allocatable :: temp(:)

        ! Increase array size
        num_visited = num_visited + 1

        if (allocated(visited)) then
            allocate(temp(num_visited-1))
            temp = visited  ! Copy existing data
            deallocate(visited)
            allocate(visited(num_visited))
            visited(:num_visited-1) = temp  ! Copy back to the new array
            deallocate(temp)
        else
            allocate(visited(num_visited))
        end if

        ! Add the new coordinate
        visited(num_visited)%x = x
        visited(num_visited)%y = y
    end subroutine add_coordinate

    logical function is_visited(visited, num_visited, x, y)
        implicit none
        type(coordinate), intent(in) :: visited(:)
        integer, intent(in) :: num_visited
        integer, intent(in) :: x, y
        integer :: i

        is_visited = .false. ! weird syntax but ok

        do i = 1, num_visited
            if (visited(i)%x == x .and. visited(i)%y == y) then
                is_visited = .true.
                return
            end if
        end do
    end function is_visited

    logical function is_in_bounds(x, y, xmax, ymax)
        implicit none
        integer, intent(in) :: x, y, xmax, ymax

        if (x <= 0 .or. y <= 0 .or. x > xmax .or. y > ymax) then
            is_in_bounds = .false.
        else
            is_in_bounds = .true.
        end if
    end function is_in_bounds

    recursive subroutine flood_fill(matrix, visited, num_visited, x, y, currentchar, cedges, area)
        implicit none
        character(1), dimension(:,:), intent(in) :: matrix
        type(coordinate), allocatable, dimension(:), intent(inout) :: visited
        integer, intent(inout) :: num_visited
        integer, intent(in) :: x, y
        character(1), intent(in) :: currentchar
        integer, intent(inout) :: cedges, area
        integer :: ox, oy, i
        logical :: in_bounds
        character(1) :: edgechar

        in_bounds = is_in_bounds(x, y, size(matrix, 2), size(matrix, 1))
        if (.not. in_bounds) return
        if (is_visited(visited, num_visited, x, y)) return
        if (matrix(y, x) /= currentchar) return

        ! Mark the current position as visited
        call add_coordinate(visited, num_visited, x, y)
        area = area + 1  ! Increment the area for this character

        ! Check surrounding directions and count edges
        do i = 1, 4
            ox = x + DIRECTIONS(i)%x
            oy = y + DIRECTIONS(i)%y

            if (is_in_bounds(ox, oy, size(matrix, 2), size(matrix, 1))) then
                edgechar = matrix(oy, ox)
                if (edgechar /= currentchar) then
                    ! This is an edge
                    cedges = cedges + 1
                else
                    ! Continue flood-fill on the neighboring cell
                    call flood_fill(matrix, visited, num_visited, ox, oy, currentchar, cedges, area)
                end if
            else
                ! Out of bounds, it's an edge
                cedges = cedges + 1
            end if
        end do
    end subroutine flood_fill
end module stuff