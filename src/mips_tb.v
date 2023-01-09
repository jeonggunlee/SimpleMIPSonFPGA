`timescale 1ns/1ps

module mips_tb;

	reg	clk, reset;
	wire clock_out;
	wire [7:0] memByte;

	mips_single my_mips (clk, reset, clock_out, memByte);

	initial
	begin
		clk = 0;
		reset = 1;
		#150;
		reset = 0;
		#10000
		$finish;
	end

	always #100 clk = ~clk;

endmodule