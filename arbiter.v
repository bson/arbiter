// Asynchronous 2 to 1 priority arbiter.  The selection is carried
// through.
// Note that priority 0 is the highest.

module arb2_1 #(
    parameter PRIO_BITS = 3,
    parameter SEL_W = 1
) (
   input wire                 req_i_a,    // 2 input requests
   input wire [SEL_W-1:0]     sel_i_a,  // selection input
   input wire [PRIO_BITS-1:0] prio_i_a, // 3-bit input request priority	
   input wire                 req_i_b,    // 2 input requests
   input wire [SEL_W-1:0]     sel_i_b,  // selection input
   input wire [PRIO_BITS-1:0] prio_i_b, // 3-bit input request priority
   
   output wire [SEL_W-1:0]     sel_o,  // selection output
   output wire                  req_o,  // output request
   output wire [PRIO_BITS-1:0] prio_o // 3-bit request priority
);


   wire maxprio;
   assign maxprio = prio_i_b > prio_i_a ? 0 : 1;

   assign req_o = req_i_a || req_i_b;
   assign sel_o = 
				req_i_a && !req_i_b ? sel_i_a :
				!req_i_a && req_i_b ? sel_i_b :
				maxprio ? sel_i_b : sel_i_a;
	assign prio_o =
				req_i_a && !req_i_b ? prio_i_a :
				!req_i_a && req_i_b ? prio_i_b :
				maxprio ? prio_i_b : prio_i_a;		// both or neither req active

endmodule // arb2_1


// Asynchronous priority arbiter with N sources.
// PRIO_BITS determines the priority value size.
//
// One or more of the N sources asserts its request line (bundled up
// in req_i).
// With its request it provides a priority.
// The output of the tree is a request indicating one or more requests
// are asserted, along with the index of the highest priority source,
// and its priority value.
// Priority 0 is the highest.

module priority_arbiter #(
   parameter N = 8,             // Default 8 sources
   parameter PRIO_BITS = 3      // Default 0-7
) (
   input wire [N-1:0]           req_i,  // source requests
   input wire [N*PRIO_BITS-1:0] prio_i, // source priorities, packed as N sets of PRIO_BITS

   output wire                  req_o,  // output request
   output wire [$clog2(N)-1:0] sel_o,  // source selection
   output wire [PRIO_BITS-1:0] prio_o   // selected source priority
);

   // For N sources we need a depth of log2(N).  This means for 8
   // sources we need three levels, consisting of 1, 2, and 4 nodes.
   // The 4 leaf nodes have 8 inputs consisting of the 8 sources.  We
   // number the leaf level 3 and the level with a single root node 0.
   // The nodes on a level are numbered starting at 0.
`define IX(L,N)  ((1 << (L)) - 1 + (N)) // Index of level L, node N
`define ROOT_L   (0)                     // Root level
`define ROOT_N   (0)                     // Root node index
`define LEAF_L   ($clog2(N)-1)           // Leaf level
`define LEAF(N)  (`IX((`LEAF_L), (N)))  // Leaf node N
`define SLW(L)   (`LEAF_L - (L) + 1)    // Selection width at level L
`define EVC(L,N) (`IX((L)+1, 2 * (N)))   // Even child
`define ODC(L,N) (`IX((L)+1, 2 * (N) + 1)) // Odd child

   // The SEL_O bit field is a bit complicated.  We take the simple
   // approach here and overprovision, then rely on the synthesizer to
   // eliminate unused wires.

   wire                   req_w[N-2:0];
   wire [`LEAF_L:0]      sel_w[N-2:0];   // Sparse
   wire [PRIO_BITS-1:0]  prio_w[N-2:0];
   
`define PRIO_BIT_FIRST(N, OE) \	(N * 2 * PRIO_BITS + (PRIO_BITS * OE) + PRIO_BITS - 1)
`define PRIO_BIT_LAST(N, OE)  (N * 2 * PRIO_BITS + (PRIO_BITS * OE))
`define PRIO_BITS(N, OE) `PRIO_BIT_FIRST(N,OE):`PRIO_BIT_LAST(N,OE)
   
   genvar l, n;
   generate
       for (l = 0; l < $clog2(N); l = l + 1) begin
           for (n = 0; n < (1 << l); n = n + 1) begin
               if (l == `LEAF_L) begin : a_
                    // Leaf node
                    arb2_1 #(
                         .PRIO_BITS(PRIO_BITS),
                         .SEL_W(`SLW(`LEAF_L))
                      ) a0_ (
                         .req_i_a(req_i[n * 2]),
                         .sel_i_a(1'b0),
						  .prio_i_a(prio_i[`PRIO_BITS(n, 0)]),

						  .req_i_b(req_i[n * 2 + 1]),
						  .sel_i_b(1'b1),
						  .prio_i_b(prio_i[`PRIO_BITS(n, 1)]),

                         .req_o(req_w[`LEAF(n)]),
                         .sel_o(sel_w[`LEAF(n)][0:0]),
                         .prio_o(prio_w[`LEAF(n)])
                    );
                    assign sel_w[`LEAF(n)][1:1] = n & 1;  // identify this node as L/R
                end else begin
                    // Branch or root node
                    arb2_1 #(
                         .PRIO_BITS(PRIO_BITS),
                         .SEL_W(`SLW(l))
                      ) a1_ (
                         .req_i_a(req_w[`EVC(l, n)]),      
                         .sel_i_a(sel_w[`EVC(l, n)][`SLW(l)-1:0]),
                         .prio_i_a(prio_w[`EVC(l, n)]),    

                         .req_i_b(req_w[`ODC(l, n)]),
                         .sel_i_b(sel_w[`ODC(l, n)][`SLW(l)-1:0]),
                         .prio_i_b(prio_w[`ODC(l, n)]),

                         .req_o(req_w[`IX(l, n)]),
                         .sel_o(sel_w[`IX(l, n)][`SLW(l)-1:0] ),
                         .prio_o(prio_w[`IX(l, n)])
                   );
                   if (l != `ROOT_L)
                     assign sel_w[`IX(l,n)][`LEAF_L - l + 1] = n & 1;
               end
           end // for (n = 0; n < (1 << l); n = n + 1)
       end // for (l = 0; l < $clog2(N); l = l + 1)
   endgenerate
   
   // Outputs
   assign req_o = req_w[`ROOT_N];
   assign sel_o = sel_w[`ROOT_N][`SLW(1):0];
   assign prio_o = prio_w[`ROOT_N];
   
endmodule // priority_arbiter

