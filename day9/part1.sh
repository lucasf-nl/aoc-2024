rm ./part1

ocamlfind ocamlc -package str -package batteries.unthreaded -linkpkg -g -o part1 part1.ml && \
./part1
