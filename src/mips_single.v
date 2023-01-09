// Jeong-Gun Lee (jeonggun.lee@hallym.ac.kr)
//-----------------------------------------------------------------------------
// Title         : MIPS Single-Cycle Processor
// Project       : ECE 313 - Computer Organization
//-----------------------------------------------------------------------------
// File          : mips_single.v
// Author        : John Nestor  <nestorj@lafayette.edu>
// Organization  : Lafayette College

module mips_single(clk, reset, clk_out, memByte);
    input clk, reset;
	 output clk_out;
	 output [7:0] memByte;
	 
    // instruction bus
    wire [31:0] instr;
	 wire [31:0] memZero;
	 
    // break out important fields from instruction
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    wire [15:0] immed;
    wire [31:0] extend_immed, b_offset;
    wire [25:0] jumpoffset;
	 
	 // For MIPS Verification
	 wire [31:0] pcOffset;
	 wire Halt;
	 
    assign opcode = instr[31:26];
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign shamt = instr[10:6];
    assign funct = instr[5:0];
    assign immed = instr[15:0];
    assign jumpoffset = instr[25:0];

    // sign-extender
    assign extend_immed = { {16{immed[15]}}, immed };
    
    // branch offset shifter
    assign b_offset = extend_immed << 2;

    // datapath signals
    wire [4:0] rfile_wn;
    wire [31:0] rfile_rd1, rfile_rd2, rfile_wd, alu_b, alu_out, b_tgt, pc_next,
                pc, pc_incr, br_add_out, dmem_rdata;
    
    // control signals

    wire RegWrite, Branch, PCSrc, RegDst, MemtoReg, MemRead, MemWrite, ALUSrc, Zero;
    wire [1:0] ALUOp;
    wire [2:0] Operation;
	 
	 // For Clock Verification
	 assign clk_out = clk;
	 // For Reset Verification
	 assign memByte[7] = reset;
	 // For Halt Verification
	 assign memByte[6] = Halt;
		 
    // module instantiations

    reg32		PC(clk, reset, pc_next, pc);
	 
	 assign	pcOffset = (Halt) ? 32'd0 : 32'd4;
	 
    add32 		PCADD(pc, pcOffset, pc_incr);

    add32 		BRADD(pc_incr, b_offset, b_tgt);

    reg_file	RFILE(clk, RegWrite, rs, rt, rfile_wn, rfile_rd1, rfile_rd2, rfile_wd); 

    alu 			ALU(Operation, rfile_rd1, alu_b, alu_out, Zero);

    rom32 		IMEM(pc, instr);

    mem32 		DMEM(clk, MemRead, MemWrite, alu_out, rfile_rd2, dmem_rdata, memZero);
	 assign		memByte[3:0] = memZero[3:0]; // Expect RESET HALT 00 0110
	 //assign		memByte = 8'b0000_1111;
	 //assign		memByte[4:0] = pc[6:2];
	 
    and  		BR_AND(PCSrc, Branch, Zero);

    mux2 #(5) 	RFMUX(RegDst, rt, rd, rfile_wn);

    mux2 #(32)	PCMUX(PCSrc, pc_incr, b_tgt, pc_next);

    mux2 #(32) ALUMUX(ALUSrc, rfile_rd2, extend_immed, alu_b);

    mux2 #(32)	WRMUX(MemtoReg, alu_out, dmem_rdata, rfile_wd);

    control_single CTL(.opcode(opcode), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), 
                       .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), 
                       .ALUOp(ALUOp), .Halt(Halt));

    alu_ctl 	ALUCTL(ALUOp, funct, Operation);
	 
	 // For Verification of Clock Circuitry
	 reg [31:0] count;
	 
	 always @(posedge clk)
	 begin
		if(reset) count = 0;
		else count = count + 1;
	 end
	 assign memByte[5] = count[24];
	 
endmodule
