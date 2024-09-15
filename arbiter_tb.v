`timescale 1ns / 1ps

module arbiter_tb();

wire req8_3;
wire [2:0] sel8_3;
wire [2:0] prio8_3;

reg [3*8-1:0] prio8_3_i;
reg [7:0] req8_3_i;
	

task automatic verify8_3;
	input req_e;
	input [2:0] sel_e;
	input [2:0] prio_e;
	
	begin
		if (req8_3 !== req_e)
			$display("%4gns REQ is %b, expected %b", $time, req8_3, req_e);
		
		if (sel8_3 !== sel_e)
			$display("%4gns SEL is %d, expected %d", $time, sel8_3, sel_e);
			
		if (prio8_3 !== prio_e)
			$display("%4gn PRIO is %d, expected %d", $time, prio8_3, prio_e);
	end
	
endtask

reg clk = 0;
initial
	forever
		#5 clk = ~clk;
		
reg req8_3_copy;
reg [2:0]sel8_3_copy;
reg [2:0]prio8_3_copy;

always @ (posedge clk) begin
	req8_3_copy <= req8_3;
	sel8_3_copy <= sel8_3;
	prio8_3_copy <= prio8_3;
end

initial begin
	$display("%4g BEGIN TEST", $time);

	#2
	prio8_3_i = { 3'd1, 3'd2, 3'd3, 3'd4, 3'd0, 3'd5, 3'd6, 3'd7 };
	req8_3_i  = { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1 };
	
	#5
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
