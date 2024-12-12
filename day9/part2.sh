rm ./part2

ocamlfind ocamlc -package str -package batteries.unthreaded -linkpkg -g -o part2 part2.ml && \
./part2
