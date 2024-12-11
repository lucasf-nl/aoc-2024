rm ./part1

ocamlfind ocamlopt -package str -package batteries.unthreaded -linkpkg -o part1 part1.ml && \
./part1
