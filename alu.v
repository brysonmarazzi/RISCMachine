
module ALU(Ain,Bin,ALUop,out,nvz);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output [2:0] nvz; //bit 0 refers to whether the output sums to 0
		    //bit 1 refers to whether or not overflow occured.
		    //bit 2 denotes if the number is negative or positive.  
  reg [15:0] outTemp; 
  reg [2:0] nvzTemp; 
//given a value of ALUop, we assign the result of an operation on Ain and Bin to a reg
always@(*) begin
  case (ALUop)
    2'b00: outTemp = Ain + Bin;
    2'b01: outTemp = Ain - Bin;
    2'b10: outTemp = Ain & Bin;
    2'b11: outTemp = ~Bin;
  endcase

  if(outTemp == 0) nvzTemp[0] = 1; 
  else nvzTemp[0] = 0; 

  if(outTemp[15] == 1) nvzTemp[2] = 1;
  else nvzTemp[2] = 0;

//The compuatation of overflow was taken from another students project. The contributers are mentined in the contributions.txt
if (
((Ain[15]&Bin[15])&&(ALUop==2'd0)&&(~out[15]))||
((~Ain[15]&~Bin[15])&&(ALUop==2'd0)&&(out[15]))||
((Ain[15]&~Bin[15])&&(ALUop==2'd1)&&(~out[15]))||
((~Ain[15]&Bin[15])&&(ALUop==2'd1)&&(out[15]))
) nvzTemp[1] = 1; //if out overflows v is one
else nvzTemp[1] = 0;


 

end
assign nvz = nvzTemp; 
assign out = outTemp; 
endmodule 