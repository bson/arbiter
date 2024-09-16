`timescale 1ns / 1ps

module arbiter_tb();

wire req8_3;
wire [2:0] sel8_3;
wire [2:0] prio8_3;

reg [3*8-1:0] prio8_3_i;
reg [7:0] req8_3_i;

reg [7:0] count = 0;

task automatic verify8_3;
	input req_e;
	input [2:0] sel_e;
	input [2:0] prio_e;
	
	begin
		if (req_e !== 1'bx && req8_3 !== req_e)
			$display("%4gns REQ is %b, expected %b (test #%d)", $time, req8_3, req_e, count);
		
		if (sel_e !== 3'bxxx && sel8_3 !== sel_e)
			$display("%4gns SEL is %d, expected %d (test #%d)", $time, sel8_3, sel_e, count);
			
		if (prio_e !== 3'bxxx && prio8_3 !== prio_e)
			$display("%4gns PRIO is %d, expected %d (test #%d)", $time, prio8_3, prio_e, count);
		count = count + 1;
	end
	
endtask


initial begin
	$display("%4g BEGIN TEST", $time);
	
	// 0 Basic

	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd0);
	
	
	// 1 Above, in all positions

	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd7, 3'd5, 3'd6, 3'd0 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd0, 3'd0);
	
	// 2
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd6, 3'd5, 3'd0, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd1, 3'd0);
	
	// 3
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd5, 3'd0, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd2, 3'd0);
	
	// 4
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd0, 3'd4, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd4, 3'd0);
	
	// 5
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd0, 3'd4, 3'd3, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd5, 3'd0);
	
	// 6
	#2
	prio8_3_i = { 3'd1, 3'd0, 3'd3, 3'd4, 3'd2, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd6, 3'd0);
	
	// 7
	#2
	prio8_3_i = { 3'd0, 3'd2, 3'd3, 3'd4, 3'd1, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd7, 3'd0);
	
	// 8 Reversed
	#2
	prio8_3_i = { 3'd7, 3'd6, 3'd5, 3'd4, 3'd0, 3'd3, 3'd2, 3'd1 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd0);
	
	
	// 9 Single req
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd0);
	
	// 10 Non-zero prio
	#2
	prio8_3_i = { 3'd5, 3'd7, 3'd6, 3'd5, 3'd3, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd3);	
	
	// 11 No req in, no req out
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
	
	#6
	verify8_3(1'b0, 3'dx, 3'dx);
	
	// 12 Two reqs at extreme ends
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd7, 3'd1);
	
	// 13 Left (upper) half req
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0 };
	
	#6
	verify8_3(1'b1, 3'd7, 3'd1);
	
	
	// 14 Right (lowe) half req
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd0);
	
	// 15 All req
	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
	
	#6
	verify8_3(1'b1, 3'd3, 3'd0);
	
	$display("%4g END TEST", $time);

end


priority_arbiter #(
	.N(8),
	.PRIO_BITS(3)
) arb8_3 (
	.req_i(req8_3_i),
	.prio_i(prio8_3_i),
	.req_o(req8_3),
	.sel_o(sel8_3),
	.prio_o(prio8_3)
);

wire [0:0] sel_o_2_1_3;
wire req_o_2_1_3;
wire [2:0] prio_o_2_1_3;

arb2_1 #( .PRIO_BITS(3), .SEL_W(1) ) arb2_1_3 (
	.req_i_a(1'b1),
	.sel_i_a(1'b0),
	.prio_i_a(3'd6),
	.req_i_b(1'b1),
	.sel_i_b(1'b1),
	.prio_i_b(3'd1),
	.sel_o(sel_o_2_1_3),
	.req_o(req_o_2_1_3),
	.prio_o(prio_o_2_1_3)
	);

endmodule
