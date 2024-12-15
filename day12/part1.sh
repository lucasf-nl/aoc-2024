rm ./part1 2&>/dev/null
gfortran coords.f90
gfortran constants.f90
gfortran stuff.f90
gfortran part1.f90 stuff.f90 constants.f90 coords.f90 -o part1 && ./part1