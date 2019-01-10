module regfile(data_in,writenum,write,readnum,clk,data_out);
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;

wire [7:0] writenumOneHot;
wire [7:0] readnumOneHot;
wire loadA,loadB,loadC,loadD,loadE,loadF,loadG,loadH;
wire [15:0] R0,R1,R2,R3, R4,R5,R6,R7;

//decode the which register to write to into binary;
decoder writenumDecoder(writenum,writenumOneHot);
//decode the which register to read from into binary;
decoder readnumDecoder(readnum,readnumOneHot);

assign loadA = (writenumOneHot[0]&&write) ? 1'b1 : 1'b0;
assign loadB = (writenumOneHot[1]&&write) ? 1'b1 : 1'b0;
assign loadC = (writenumOneHot[2]&&write) ? 1'b1 : 1'b0;
assign loadD = (writenumOneHot[3]&&write) ? 1'b1 : 1'b0;
assign loadE = (writenumOneHot[4]&&write) ? 1'b1 : 1'b0;
assign loadF = (writenumOneHot[5]&&write) ? 1'b1 : 1'b0;
assign loadG = (writenumOneHot[6]&&write) ? 1'b1 : 1'b0;
assign loadH = (writenumOneHot[7]&&write) ? 1'b1 : 1'b0;

//Instatiate 8 registers
vRegLoadEnable r0(clk, loadA, data_in, R0);
vRegLoadEnable r1(clk, loadB, data_in, R1);
vRegLoadEnable r2(clk, loadC, data_in, R2);
vRegLoadEnable r3(clk, loadD, data_in, R3);
vRegLoadEnable r4(clk, loadE, data_in, R4);
vRegLoadEnable r5(clk, loadF, data_in, R5);
vRegLoadEnable r6(clk, loadG, data_in, R6);
vRegLoadEnable r7(clk, loadH, data_in, R7);

vMux8 mux(R7,R6,R5,R4,R3,R2,R1,R0,readnumOneHot,data_out); 
endmodule

//Decoder that defaults to 3:8 if no prarmeter is specified
//Binary to one-hot-code 
module decoder(a,b);
parameter n = 3;
parameter m = 8;

input [n-1:0] a;
output [m-1:0] b;
assign b = 1 << a;
endmodule 

//Regester with Load Enable, that defaults to 16 bit data input if no prarmeter is specified
module vRegLoadEnable(clk,load,in,out);
parameter n = 16;
input clk, load;
input [n-1:0] in;
output [n-1:0] out;
reg [n-1:0] out;
wire [n-1:0] next_out;
 
//If the load is true then update the value, otherwise assign the original value again.
assign next_out = load ? in : out; 

always @(posedge clk) begin
out = next_out;
end
endmodule 

//Mux that takes 8 inputs and defaults to 16 bit wid input an outputs if not specified.
module vMux8(a7,a6,a5,a4,a3,a2,a1,a0,select,out);
parameter n = 16;
input [n-1:0] a7,a6,a5,a4,a3,a2,a1,a0; //Inputs 
input [7:0] select;
output [n-1:0] out; 
assign out =    ({n{select[0]}} & a0) | 
		 ({n{select[1]}} & a1) | 
		 ({n{select[2]}} & a2) | 
		 ({n{select[3]}} & a3) | 
		 ({n{select[4]}} & a4) | 
		 ({n{select[5]}} & a5) | 
		 ({n{select[6]}} & a6) | 
		 ({n{select[7]}} & a7) ;
endmodule

