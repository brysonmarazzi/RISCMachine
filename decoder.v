module instructionDecoder(in, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum,cond);
  input [15:0] in;
  input [2:0] nsel;
  output [1:0] ALUop, shift, op;
  output reg[2:0] readnum;
  output [2:0] opcode, writenum,cond;
  output reg[15:0] sximm5, sximm8;
 
  assign opcode = in[15:13];
  assign op = in[12:11];
  assign ALUop = in[12:11];
  assign shift = in[4:3];
  assign cond = in[10:8]; 

  always @(*) begin
  //mux that assigns readnum proper bits of in based on nsel
    case(nsel)
      3'b001: readnum = in[10:8]; //Rn
      3'b010: readnum = in[7:5]; //Rd
      3'b100: readnum = in[2:0]; //Rm
      default: readnum = 3'bx;
    endcase
  end
  assign writenum = readnum;
  

  always @(*) begin
  //get sign extension of first 5 bits of in
    sximm5 = {{11{in[4]}}, in[4:0]};
  end
  always @(*) begin
  //get sign extension of first 8 bits of in
    sximm8 = {{8{in[7]}}, in[7:0]};
  end

endmodule
