module datapath(clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads
		,writenum,write,sximm5,mdata,sximm8,PC,datapath_out,N,V,Z);
// sximm8 substitutes datapath_in
input clk;
input [15:0] mdata, sximm8, sximm5;
input [7:0] PC; 
input write, loada, loadb, asel, loadc, loads;
input [1:0] vsel, bsel;
input [2:0] readnum, writenum;
input [1:0] shift, ALUop;
output [15:0] datapath_out;
output N,V,Z;
wire [15:0] data_out, aout, bout, sout, Bin, Ain, ALUout;
wire [2:0] nvz;
reg [15:0] data_in;
wire [2:0] NVZ_out; 

//Assuming vsel is binary, no default as all states are accounted for. 
always@(*) begin
case(vsel)
2'b11: data_in = mdata;
2'b10: data_in = sximm8;
2'b01: data_in = PC+1'b1;
2'b00: data_in = datapath_out;
endcase 
end
 
regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);

vRegLoadEnable RA(clk,loada,data_out,aout);

vRegLoadEnable RB(clk,loadb,data_out,bout);

shifter SHIFT(bout,shift,sout); 

vMux3 MUX3b(sout,sximm5,16'b0,bsel,Bin);

vMux2 MUX2a(aout,16'b0,asel,Ain);

ALU alu(Ain, Bin, ALUop,ALUout,nvz);  

vRegLoadEnable RC(clk,loadc,ALUout,datapath_out);

vRegLoadEnable #(3) RStatus(clk,loads,nvz,NVZ_out);

assign N = NVZ_out[2]; 
assign V = NVZ_out[1];
assign Z = NVZ_out[0]; 

endmodule

//Mux that takes 2 inputs with a 1 bit select and defaults to 16 bit wid input an outputs if not specified.
//Output is assigned to a0 is select is 0 and a1 if select is 1. 
module vMux2(a0,a1,select,out);
input [15:0] a1,a0; //Inputs 
input select;
output [15:0] out;
reg [15:0] outTemp; 
always@(*) begin
if(select) outTemp = a1; 
else outTemp = a0;
end
assign out = outTemp;
endmodule


module vMux3(a0,a1,a2,select,out);
input [15:0] a2,a1,a0; //Inputs 
input [1:0] select;
output reg [15:0] out; 
always@(*) begin
case(select) 
2'b00 : out = a0; 
2'b01 : out = a1;
2'b10 : out = a2; 
2'b11 : out = a0;  //Default;
endcase
end
endmodule 