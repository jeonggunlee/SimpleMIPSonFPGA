//-----------------------------------------------------------------------------
// Title         : MIPS Single-Cycle Control Unit
// Project       : ECE 313 - Computer Organization
//-----------------------------------------------------------------------------
// File          : control_single.v
// Author        : John Nestor  <nestorj@lafayette.edu>
// Organization  : Lafayette College
//-----------------------------------------------------------------------------

module control_single(opcode, RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp, Halt);
    input [5:0] opcode;
    output RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    output [1:0] ALUOp;
	 output Halt;
    reg    RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    reg    [1:0] ALUOp;
	 reg	  Halt;

    parameter R_FORMAT = 6'd0;
    parameter LW = 6'd35;
    parameter SW = 6'd43;
    parameter BEQ = 6'd4;
    parameter HALT = 6'd63;
	 
    always @(opcode)
    begin
        case (opcode)
          R_FORMAT : 
          begin
              RegDst=1'b1; ALUSrc=1'b0; MemtoReg=1'b0; RegWrite=1'b1; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b10; Halt = 1'b0;
          end
          LW :
          begin
              RegDst=1'b0; ALUSrc=1'b1; MemtoReg=1'b1; RegWrite=1'b1; MemRead=1'b1; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b00; Halt = 1'b0;
          end
          SW :
          begin
              RegDst=1'bx; ALUSrc=1'b1; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b1; Branch=1'b0; ALUOp = 2'b00; Halt = 1'b0;
          end
          BEQ :
          begin
              RegDst=1'bx; ALUSrc=1'b0; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b1; ALUOp = 2'b01; Halt = 1'b0;
          end
          HALT :
          begin
              RegDst=1'bx; ALUSrc=1'bx; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'bx; 
              MemWrite=1'b0; Branch=1'bx; ALUOp = 2'bxx; Halt = 1'b1;
          end			 
          default
          begin
              $display("control_single unimplemented opcode %d", opcode);
              RegDst=1'bx; ALUSrc=1'bx; MemtoReg=1'bx; RegWrite=1'bx; MemRead=1'bx; 
              MemWrite=1'bx; Branch=1'bx; ALUOp = 2'bxx; Halt = 1'bx;
          end

        endcase
    end
endmodule

