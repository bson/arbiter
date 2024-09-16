# Priority Arbiter (Verilog)

This is a very basic, asynchronous priority arbiter.

Given a number of sources, each with a request wire and a priority,
this arbiter outputs the one with the highest priority.

It outputs a request to indicate there is at least one request
pending, the source, and its priority.

There is a basic testbench that walks through a sparse set of use
cases.  Better would be to exhaustively test the entire space.  Or
maybe both - if it passes the sparse test matrix, apply all of it.  If
something fails during the exhaustive test, add it to the sparse
matrix as it represents some edge case.
