`define SW 4'b0 //Waiting state
`define SA 4'b0001
`define SB 4'b0010
`define SC 4'b0011
`define SD 4'b0100
`define SE 4'b0101
`define SF 4'b0110
`define SG 4'b1000
`define SH 4'b1001
`define SDECODE 4'b0111
`define SRESET 4'b1001
`define SIF1 4'b1001
`define SIF2 4'b1010
`define SUpdatePC 4'b1011
`define R 2'b01

module cpu_tb();
reg clk,reset,s,load;
reg [15:0] in;
wire [15:0] out; 
wire N,V,Z,w;
reg err;
cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);

initial begin
clk = 1'b0; 
forever begin
		#5; clk = ~clk;
	end 
end

//Task to check the state
task checker_state;
	input [3:0] expectedS;
begin
	//Print out error message if the current state is not the expected state or is undefined or z. 
  	if(cpu_tb.DUT.fsm.presentS !== expectedS) begin
	$display("Error ** state is %b, expected %b",
		cpu_tb.DUT.fsm.presentS, expectedS);
	err = 1'b1; 	//Set the err signal to true (1) to aid in debugging. 
	end
       end
endtask

//Check the MVN instruction
task checker_MVN;
	input [2:0] Rm;
	input [2:0] Rd;
	input [1:0] shift; 
	input [15:0] expectedOut; 

begin
in = {8'b101_11_000,Rd,shift,Rm}; 
load = 1; reset = 1; s = 1;
@(posedge clk) 
 reset = 0; 
checker_state(`SW);
@(posedge clk)
checker_state(`SDECODE); 
@(posedge clk)
checker_state(`SB);
@(posedge clk)
checker_state(`SF);
@(posedge clk)
checker_state(`SD);  
@(posedge clk)
checker_state(`SW);
//Check output
if(out !== expectedOut) begin 
$display("Error ** out is %b, expected %b",
		out, expectedOut);
	err = 1'b1; 	//Set the err signal to true (1) to aid in debugging. 
			end
	end
endtask

task checker_MOV_SH;
	input [2:0] Rm;
	input [2:0] Rd;
	input [1:0] shift; 
	input [15:0] expectedOut; 

begin
in = {8'b110_00_000,Rd,shift,Rm}; //2 shifted 1 to the left (so 4) and AND it with 7 and store it in R5
load = 1; reset = 1; s = 1;
@(posedge clk) 
 reset = 0; 
checker_state(`SW);
@(posedge clk)
checker_state(`SDECODE); 
@(posedge clk)
checker_state(`SB);
@(posedge clk)
checker_state(`SF);
@(posedge clk)
checker_state(`SD);  
@(posedge clk)
checker_state(`SW);
//Check output
if(out !== expectedOut) begin 
$display("Error ** out is %b, expected %b",
		out, expectedOut);
	err = 1'b1; 	//Set the err signal to true (1) to aid in debugging. 
			end
	end
endtask

//Check the CMP instruction
task checker_CMP;
	input [2:0] Rn;
	input [2:0] Rm;
	input [1:0] shift;  
	input expectedZ;  
begin
in = {5'b10101,Rn,3'b0,shift,Rm}; //2 shifted 1 to the left (so 4) and AND it with 7 and store it in R5
load = 1; reset = 1; s = 1;
@(posedge clk) 
 reset = 0; 
checker_state(`SW);
@(posedge clk)
checker_state(`SDECODE); 
@(posedge clk)
checker_state(`SA);
@(posedge clk)
checker_state(`SB);
@(posedge clk)
checker_state(`SC);  
@(posedge clk)
checker_state(`SG);
@(posedge clk)
checker_state(`SW);
//Check output
if(Z !== expectedZ) begin 
$display("Error ** Z is %b, expected %b",
		Z, expectedZ);
	err = 1'b1; 	//Set the err signal to true (1) to aid in debugging. 
			end
	end 
endtask

//Task to check the add and and instructions
task checker_ADD_AND;
	input [2:0] Rn;
	input [2:0] Rm;
	input [2:0] Rd;
	input [1:0] shift;
	input [1:0] ALUop; 
	input [15:0] expectedOut; 
begin
in = {3'b101,ALUop,Rn,Rd,shift,Rm}; //2 shifted 1 to the left (so 4) and AND it with 7 and store it in R5
load = 1; reset = 1; s = 1;
@(posedge clk) 
 reset = 0; 
checker_state(`SW);
@(posedge clk)
checker_state(`SDECODE); 
@(posedge clk)
checker_state(`SA);
@(posedge clk)
checker_state(`SB);
@(posedge clk)
checker_state(`SC);  
@(posedge clk)
checker_state(`SD);
@(posedge clk)
checker_state(`SW);
//Check output
if(out !== expectedOut) begin 
$display("Error ** out is %b, expected %b",
		out, expectedOut);
	err = 1'b1; 	//Set the err signal to true (1) to aid in debugging. 
			end
	end 
endtask



task checker_MOV;
	input [2:0] desiredRn;
	input [7:0] desiredNumber;
begin
reset = 1;
@(posedge clk)
in = {5'b11010,desiredRn,desiredNumber}; s = 1; reset = 0; checker_state(`SW);
@(posedge clk) checker_state(`SDECODE); s = 0; 
@(posedge clk) checker_state(`SE); 
@(posedge clk) checker_state(`SW);
       end
endtask


//check the MOV, ADD, and AND path of the FSM
initial begin
 
reset = 0; s = 0; load = 1; err = 0; 
checker_MOV(3'b000,8'b00000111); //Load R0 with decimal 7
checker_MOV(3'b001,8'b00000010); //Load R1 with decimal 2
//Rm,Rd,shift,expectedOut
checker_MOV_SH(3'b000,3'b111,2'b01,16'b0000000000001110); //Take a number from R0 (7) and times by 2 and store result in R7
 //Rn,Rm,Rd,shift,ALUop,expectedOut
checker_ADD_AND(3'b000,3'b001,3'b010,2'b00,2'b00,16'b0000000000001001); //Add contents of R0 with contents of R1 and store in R2
checker_ADD_AND(3'b001,3'b000,3'b011,2'b01,2'b10,16'b0000000000000010); //AND contents of R1 with contents of R0 shfited left and store in R3
//Rn,Rm,shift,expectedZ
checker_CMP(3'b000,3'b000,2'b00,1); //Take contents of R0 and compare with contents of R0, Z should flag the result.
//Check overflow nad negative
if(V !== 0) begin
$display("Error! V is %b should be 0",V);
err = 1; 
end
if(N !== 0) begin
$display("Error! N is %b should be 0",N);
err = 1; 
end
checker_MVN(3'b000,3'b101,2'b00,16'b1111111111111000); //Take contents of R0 and NOT it and store in R5

//The following test edge cases some with value binary all 1s.  
checker_MOV(3'b100,8'b11111111); //Load R4 with -1
checker_MOV_SH(3'b001,3'b111,2'b10,16'b0000000000000001); //Take a number from R1(2) and divide by 2 and overwrite R7 with results
checker_ADD_AND(3'b100,3'b100,3'b110,2'b00,2'b00,16'b1111111111111110); //ADD -1 with itself and store in R6
checker_ADD_AND(3'b100,3'b100,3'b010,2'b00,2'b10,16'b1111111111111111); //AND contents of R4 with itself shifter to the left and store in R2 
checker_MVN(3'b010,3'b111,2'b00,16'b0000000000000000); //Take contents of R0 and NOT it and store in R7
checker_MOV(3'b001,8'b00000111); //Load R1 with 7
checker_MOV(3'b010,8'b00000001); //Load R2 with 1
checker_CMP(3'b010,3'b001,2'b00,0); //Take contents of R4 and compare with itself shifted to the right, Z should flag 0 result.
if(V !== 1) begin
$display("Error! V is %b should be 0",V);
err = 1; 
end
if(N !== 1) begin
$display("Error! N is %b should be 0",N);
err = 1; 
end


//The following tests edge cases with 0 
checker_MOV(3'b000,8'b0); //Overwrite R0 with 0
checker_MOV(3'b001,8'b0); //Overwrite R1 with 0
checker_MOV_SH(3'b000,3'b111,2'b10,16'b0000000000000000); //Shift number 0 1 bit to the right and overwrite R7 with results
checker_ADD_AND(3'b000,3'b001,3'b011,2'b01,2'b00,16'b0); //ADD 0 to 0 shifted 1 bit to the left and store in R3
checker_ADD_AND(3'b000,3'b001,3'b010,2'b00,2'b10,16'b0000000000000000); //AND 0 with 0 and store in R2
checker_CMP(3'b001,3'b000,2'b10,1); //compare 0 to 0 shifted to the right, Z should flag 1 result.
checker_MVN(3'b001,3'b111,2'b01,16'b1111111111111111); //Take contents of R0 shift to the left and NOT it and store in R7


if(~err) begin $display("Passed!");end
else begin $display("Failed!"); end
end
endmodule

