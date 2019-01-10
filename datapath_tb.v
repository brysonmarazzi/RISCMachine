module datapath_tb();

reg clk;
reg write, loada, loadb, asel, bsel, loadc, loads;
reg [2:0] readnum, writenum;
reg [1:0] shift, ALUop, vsel;
wire [15:0] datapath_out;
wire Z_out, N_out, V_out;
wire [15:0] mdata, sximm5;
reg [15:0] sximm8;
wire [7:0] PC;
reg err; 


datapath DUT(clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads
		,writenum,write,sximm5,mdata,sximm8,PC,datapath_out,N_out,V_out,Z_out);
initial begin
		clk = 1'b0;
	forever begin
		#5; clk = ~clk;
	end
end

initial begin
err = 0;
sximm8 = 16'b0000000010101001; //Decimal 169
write = 1; vsel = 2'b10; writenum = 3'b011; //Controls to load 169 into R3
readnum = 3'b011; 
loada = 0; loadb = 0; loadc = 0; loads = 0; asel = 1; bsel = 1; 
shift = 2'b00; ALUop = 2'b01; 
@(posedge clk) //load number 169 into R3
sximm8 = 16'b0000000001100100; //Decimal 100
writenum = 3'b100; //Load decimal 100 into R4, (write is still 1)
@(posedge clk)  
write = 0; loada = 1; //Load contents of R3 into RA. 
@(posedge clk)
loada = 0; readnum = 3'b100; loadb = 1; //Load contents of R4 into RB
@(posedge clk)
loadb = 0; asel = 0; bsel = 0; loadc = 1; //Load the result of the alu into RC
@(posedge clk) 
loadc = 0; vsel = 0;  write = 1; writenum = 3'b101; 
@(posedge clk)
readnum = 3'b101; 
$display("169 - 100 = 69. Output should be 69. output is %b", datapath_out);
if(datapath_out !== 16'b0000000001000101) err = 1;

//Load 7 into R0
//Load 2 into R1
//Shift binary 2 to the left to obtian binary 4 and add them together
//load into R2
//Read from R2

sximm8 = 16'b0000000000000111; //Decimal 7; 
writenum = 3'b000; readnum = 3'b000; loada = 0; loadb = 0; loadc = 0;
vsel = 2'b10; asel = 1; bsel = 1; shift = 2'b01; ALUop = 2'b00; 
@(posedge clk) 
sximm8 = 16'b0000000000000010; //Decimal 2; 
writenum = 3'b001; 
@(posedge clk)
loadb = 1; write = 0; //Load contents of R0 into Rb
@(posedge clk)
loadb = 0; loada = 1; readnum = 3'b001;  //Load contents of R1 into Ra
@(posedge clk)
loada = 0; asel = 0; bsel = 0; loadc = 1; //Load result of ALU into Rc
@(posedge clk)
loadc = 0; vsel = 0;  write = 1; writenum = 3'b010; //Load contents of Rc into R2
@(posedge clk) 
readnum = 3'b010; 
$display("7*2 + 2 = 16. Output should be 16. output is %b", datapath_out);
if(datapath_out !== 16'b0000000000010000) err = 1;

//subtract 7 from two should result in a negative number
shift = 2'b00; loadb = 1; write = 0; ALUop = 2'b01;//Load contents of R0 into Rb
@(posedge clk)
loadb = 0; loada = 1; readnum = 3'b001;  //Load contents of R1 into Ra
@(posedge clk)
loada = 0; asel = 0; bsel = 0; loadc = 1; loads = 1; //Load result of ALU into Rc
@(posedge clk)
loadc = 0; vsel = 0;  write = 1; writenum = 3'b010; loads = 0; //Load contents of Rc into R2
@(posedge clk) 
readnum = 3'b010; 
$display("N should be 1, actual is %b", N_out);
if(N_out !== 1'b1) err = 1;

//load 32767 into R0
//add 2
//should result in overflow error
sximm8 = 16'b0111111111111111; //Decimal 32767; 
writenum = 3'b000; readnum = 3'b000; loada = 0; loadb = 0; loadc = 0;
vsel = 2'b10; asel = 1; bsel = 1; shift = 2'b00; ALUop = 2'b00; 
@(posedge clk) 
sximm8 = 16'b0000000000000010; //Decimal 2; 
writenum = 3'b001; 
@(posedge clk)
loadb = 1; write = 0; //Load contents of R0 into Rb
@(posedge clk)
loadb = 0; loada = 1; readnum = 3'b001;  //Load contents of R1 into Ra
@(posedge clk)
loada = 0; asel = 0; bsel = 0; loadc = 1; loads = 1; //Load result of ALU into Rc
@(posedge clk)
loadc = 0; vsel = 0;  write = 1; writenum = 3'b010; loads = 0; //Load contents of Rc into R2
@(posedge clk) 
readnum = 3'b010; 
$display("V should be 1, acutual is %b", V_out);
if(V_out !== 1'b1) err = 1;

//load 2 into R1
//subrtact 2
//should reult in zero output
sximm8 = 16'b0000000000000010; //Decimal 2; 
writenum = 3'b000; readnum = 3'b000; loada = 0; loadb = 0; loadc = 0;
vsel = 2'b10; asel = 1; bsel = 1; shift = 2'b00; ALUop = 2'b01; 
@(posedge clk) 
sximm8 = 16'b0000000000000010; //Decimal 2; 
writenum = 3'b001; 
@(posedge clk)
loadb = 1; write = 0; //Load contents of R0 into Rb
@(posedge clk)
loadb = 0; loada = 1; readnum = 3'b001;  //Load contents of R1 into Ra
@(posedge clk)
loada = 0; asel = 0; bsel = 0; loadc = 1; loads = 1;//Load result of ALU into Rc
@(posedge clk)
loadc = 0; vsel = 0;  write = 1; writenum = 3'b010; loads = 0; //Load contents of Rc into R2
@(posedge clk) 
readnum = 3'b010; 
$display("Z should be 1, acutual is %b", Z_out);
if(Z_out !== 1'b1) err = 1;
$display("output should be 16'b0000000000000000, actual is %b", datapath_out);
if(datapath_out !== 16'b0000000000000000) err = 1'b1;

//Check if there were any errors
if(err) $display("Failed!");
else $display("Passed!");
end
endmodule