module shifter(in,shift,sout); 
input [15:0] in;
input [1:0] shift; 
output [15:0] sout; 
reg [15:0] outTemp; 
always@(*) begin
case(shift)
2'b00: outTemp = in;
2'b01: outTemp = in<<1;
2'b10: outTemp = in>>1;
2'b11: begin 
outTemp = in>>1;
outTemp[15] = in[15];  
end
endcase
end
assign sout = outTemp; 
endmodule

