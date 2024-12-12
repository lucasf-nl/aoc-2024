rm ./part2

ocamlfind ocamlopt -package str -package batteries.unthreaded -linkpkg -o part2 part2.ml && \
./part2
