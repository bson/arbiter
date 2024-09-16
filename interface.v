module interface (
	input wire [7:0] req_i,
	input wire [3*8-1:0] prio_i,
	
	output wire req_o,
	output wire [2:0] sel_o,
	output wire [2:0] prio_o
);

priority_arbiter #(.N(8), .PRIO_BITS(3)) arb0 (
	.req_i(req_i),
	.prio_i(prio_i),
	
	.req_o(req_o),
	.sel_o(sel_o),
	.prio_o(prio_o)
);

endmodule
