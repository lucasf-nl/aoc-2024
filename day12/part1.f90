program hello
    use matrix_utils
    use stuff
    use constants
    implicit none

    character(1), allocatable, dimension(:,:) :: matrix
    integer :: i, i2, j, rows, cols, x, y, cedges, carea, ccost, alphaindex, total
    character(1) :: currentchar, edgechar
    ! indexed by alphabet indices
    integer :: cost(26)

    ! this is xy
    type(coordinate), allocatable :: visited(:)
    integer :: num_visited

    num_visited = 0
    allocate(visited(0))

    ! more interesting syntax, but this appears actually useful for some things
    ! https://fortran-lang.org/learn/quickstart/arrays_strings/
    cost(:) = 0

    ! call the function. matrix is yx because of how the file is read.
    ! as it is 2 am i do not care at this time.
    matrix = read_matrix_from_file("input.txt")

    rows = size(matrix, 1)
    cols = size(matrix, 2)

    do y = 1, rows
        do x = 1, cols
            if (.not. is_visited(visited, num_visited, x, y)) then
                ! get the character
                currentchar = matrix(y, x)
                cedges = 0
                carea = 0

                ! run flood fill
                call flood_fill(matrix, visited, num_visited, x, y, currentchar, cedges, carea)

                ! update state
                call add_coordinate(visited, num_visited, x, y)
                alphaindex = ichar(currentchar) - ichar('A') + 1
                cost(alphaindex) = cost(alphaindex) + (carea * cedges)
            end if
        end do
    end do

    total = 0

    do i2 = 1, 26
        currentchar = char(ichar('A') + i2 - 1)
        ccost = cost(i2)
        print *, "area by id ", currentchar, " has cost of", ccost
        total = total + ccost
    end do

    print *, "total: ", total
end program hello

module matrix_utils
    implicit none
contains

    function read_matrix_from_file(filename) result(matrix)
        character(len=*), intent(in) :: filename
        character(1), allocatable, dimension(:,:) :: matrix
        integer :: i, j, num_rows, num_cols, ios
        character(len=140) :: line
        integer :: unit_num

        num_rows = 0
        num_cols = 0

        open(unit=10, file=filename, status="old", action="read", iostat=ios)
        if (ios /= 0) then
            print *, "cant open file"
            stop
        end if

        do
            read(10, '(A)', iostat=ios) line
            if (ios /= 0) exit
            num_rows = num_rows + 1
            num_cols = max(num_cols, len_trim(line))
        end do
        rewind(10)

        allocate(matrix(num_rows, num_cols))

        ! add data in file to matrix
        i = 0
        do
            read(10, '(A)', iostat=ios) line
            if (ios /= 0) exit
            i = i + 1
            do j = 1, len_trim(line)
                matrix(i, j) = line(j:j)
            end do
        end do

        close(10)
    end function read_matrix_from_file

    subroutine print_matrix(matrix)
        character(1), intent(in), dimension(:,:) :: matrix
        integer :: i, j, rows, cols

        rows = size(matrix, 1)
        cols = size(matrix, 2)

        do i = 1, rows
            do j = 1, cols
                write(*, '(A)', advance='no') matrix(i, j)
            end do
            write(*, *) ! newline? what is this syntax
        end do
    end subroutine print_matrix

end module matrix_utils