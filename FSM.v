`define SA 5'b00001 //GetA
`define SB 5'b00010 //GetB
`define SC 5'b00011 //LoadC
`define SD 5'b00100 //LoadRd
`define SE 5'b00101 
`define SF 5'b00110
`define SDECODE 5'b00111
`define SG 5'b01000
`define SRESET 5'b01001
`define SIF2 5'b01010
`define SUpdatePC 5'b01011
`define SLDR3 5'b01100
`define SLDR4 5'b01101
`define SLDR1 5'b01110
`define SIF1 5'b01111    //  <-- IF1
`define SLDR2 5'b00000
`define SSTORE3 5'b10000
`define SBLXX 5'b11111
`define SHALT 5'b10001
`define SWHERE 5'b10011
`define SBL 5'b10111
`define SLOADR7 5'b10110
`define SBLX 5'b11010
`define SSTORE 5'b11011
`define SSTORE2 5'b11000

`define R 2'b01
`define W 2'b10

module FSM(clk,reset,cond,N,V,Z,opcode,op,nsel,vsel,write,loada,loadb,loadc,loads,asel,bsel,pc_sel,load_pc,load_ir,load_addr,addr_sel,m_cmd,led8);
				     
input [2:0] opcode,cond;
input [1:0] op;
input clk,reset,N,V,Z;
reg [4:0] presentS,next;
reg [21:0] controls; 
reg [19:0] p;
//New signals for Lab7

output reg load_ir, load_pc, addr_sel, load_addr;
output reg [1:0] pc_sel, m_cmd;   
output reg write,loada,loadb,loadc,loads,asel,led8; //Datapath controls.
output reg [2:0] nsel;  //nsel: Name select, binary select for mux to represents readnum/writenum register
output reg [1:0] vsel,bsel; //2bit datapath controls 



always@(*) begin
if(presentS == `SIF1)
p = 20'h10000;
end

//opcode = 101, ALU,
//opcode = 110, move
//op = 10, alu AND or move version 1.
//op = 00, alu addition or move version 2
//w = 1 if in the resting state
//s = 1 then start an instruction on rising edge of clk
always@(*)begin
casex({presentS,reset,opcode,op})
 {`SRESET,1'b0,5'bxxxxx}: next = `SIF1; //address in PC sent to memory
 {`SRESET,1'b1,5'bxxxxx}: next = `SRESET; //loop back to RESET
{5'bxxxxx,1'b1,5'bxxxxx}: next = `SRESET; //If you are in any state you should go back to reset if reset is hit
  {`SIF1,1'bx,5'bxxxxx}: next = `SIF2; //load the instruction register
{`SWHERE,1'bx,5'b0101x}: next = `SBL; //For instructions BL and BLX, R7 = PC
{`SWHERE,1'bx,5'b010_00} : next = `SBLXX; //Take contents of Rd and load into regB
{`SBLXX,1'bx,5'b010x0} : next = `SF; //Load alu result into Rc (asel = 1)
   {`SF,1'bx,5'b010x0} : next = `SUpdatePC; //			
   {`SWHERE,1'bx,5'bxxxxx}: next = `SUpdatePC; //Update the PC to the next instruction 1
{`SBL,1'bx,5'b01010} : next = `SBLXX; // Start settting output of DP to Rd like BX
{`SBL,1'bx,5'bxxxxx} : next = `SUpdatePC; //update PC to sximm8 + PC +1
{`SIF2,1'bx,5'bxxxxx}: next = `SWHERE; //Update the PC to the next instruction 1
{`SUpdatePC,1'bx,5'b001xx}: next = `SIF1;//address in PC sent to memory
{`SUpdatePC,1'bx,5'b010xx}: next = `SIF1;//send updated address to memory after performing branch instructions
{`SUpdatePC,1'bx,5'bxxxxx}: next = `SDECODE; //If s is one then move from waiting state to decode state
{`SDECODE,1'bx,5'b101x0}: next = `SA; //Take contents of Rn and load into Ra
{`SDECODE,1'bx,5'b10101}: next = `SA; //Take contents of Rn and load into Ra
{`SDECODE,1'bx,5'b1101x}: next = `SE; //Move immediate set nsel to Rn, vsel to sximm8 and write to 1.
{`SDECODE,1'bx,5'b1100x}: next = `SB;//Take contents of Rm and load into Rb
{`SDECODE,1'bx,5'b10111}: next = `SB; //Take contents of Rm and load into Rb
{`SDECODE,1'bx,5'b01100}: next = `SA; //Begin the load instruction
{`SDECODE,1'bx,5'b10000}: next = `SA; //Begin the store instruction
{`SDECODE,1'bx,5'b111xx}: next = `SHALT; //Begin the load instruction
 {`SHALT,1'b1,5'b111xx}: next = `SRESET; //Reset the PC to 0s. 
 {`SHALT,1'bx,5'b111xx}: next = `SHALT; //Loops back to itself until reset is hit. 
     {`SA,1'bx,5'b01100}: next = `SLDR1; //Set bsel to 1 and load sximm5 into the ALU
     {`SA,1'bx,5'b10000}: next = `SLDR1; //Set bsel to 1 and load sximm5 into the ALU
  {`SLDR1,1'bx,5'bxxxxx}: next = `SLDR2; //load the address in to the data address register
  {`SLDR2,1'bx,5'b01100}: next = `SLDR3; //Set the m_cmd to read and connect mem_adr to data address output
  {`SLDR2,1'bx,5'b10000}: next = `SSTORE; // take contents of Rd and load into Ra
  {`SLDR3,1'bx,5'bxxxxx}: next = `SLDR4; //write the input from the memory into Rd
  {`SLDR4,1'bx,5'bxxxxx}: next = `SIF1; //Set addr_sel to 0 so mem_addr is set to contents of Rd
     {`SSTORE2,1'bx,5'b10000}: next = `SSTORE3; //Set addr_sel to 0 so mem_addr is set to contents of Rd
     {`SF,1'bx,5'bxxxxx}: next = `SD; //Take output of Rc and load into Rd
     {`SE,1'bx,5'bxxxxx}: next = `SIF1; //Automatically return to waiting state once done in state E.    
     {`SA,1'bx,5'b101xx}: next = `SB; //Take contents of Rm and load into Rb
{`SSTORE,1'bx,5'b10000}: next = `SSTORE2; //asel = 1, take output of alu (aout = 16'b0) and load into Rc
     {`SB,1'bx,5'b1100x}: next = `SF; //asel = 1, take output of alu (aout = 16'b0) and load into Rc
     {`SB,1'bx,5'b10111}: next = `SF; //asel = 1, take output of alu (aout = 16'b0) and load into Rc
     {`SB,1'bx,5'bxxxxx}: next = `SC; //Default b goes to c. Take output of alu and load into Rc
     {`SC,1'bx,5'bxxx01}: next = `SG; //Same as state D except the status Register is loaded
     {`SC,1'bx,5'bxxxxx}: next = `SD; //Take output of Rc and load into Rd
     {`SG,1'bx,5'bxxxxx}: next = `SIF1; //Return to waiting state automatically from StateG
     {`SD,1'bx,5'bxxxxx}: next = `SIF1; //Return to waiting state automatically from stateD
{`SSTORE3,1'bx,5'b10000}: next = `SIF1; //Set addr_sel to 0 so mem_addr is set to contents of Rd
     		 default: next = `SIF1; //Return to the waiting state upon bad input. 
endcase
case(next)
`SDECODE: controls = {3'b001,2'b0,5'b0,3'b00,6'b0,3'b0}; //If s is one then move from waiting state to decode state
`SA : controls = {3'b001,2'b0,5'b01000,3'b00,6'b0,3'b0}; //Take contents of Rn and load into Ra
`SB : controls = {3'b100,2'b0,5'b00100,3'b00,6'b0,3'b0}; //Take contents of Rm and load into Rb
`SC : controls = {3'b100,2'b0,5'b00010,3'b00,6'b0,3'b0}; //Default b goes to c. Take output of alu and load into Rc
`SD : controls = {3'b010,2'b0,5'b10000,3'b0,6'b0,3'b0}; //Take output of Rc and load into Rd
`SE : controls = {3'b001,2'b10,5'b10000,3'b0,6'b0,3'b0}; //Move immediate set nsel to Rn, vsel to sximm8 and write to 1.
`SF : controls = {3'b100,2'b0,5'b00010,3'b100,6'b0,3'b0}; //asel = 1, take output of alu (aout = 16'b0) and load into Rc    <---
`SG : controls = {3'b100,2'b0,5'b00001,3'b0,6'b0,3'b0}; //Same as state D except the status Register is loaded
`SRESET : controls = {3'b001,2'b0,5'b0,3'b0,2'b01,4'b1000,3'b0}; //load_pc = 1, reset_pc = 1, m_cmd = 0, others are 0 or waitstate values.
`SIF1 : controls = {3'b001,2'b0,5'b0,3'b00,6'b000001,`R,1'b0}; //addr_sel = 1, m_cmd = R and others are 0 or waitstate values. 
`SIF2 : controls = {3'b001,2'b0,5'b0,3'b00,6'b000101,`R,1'b0}; //load_ir = 1, m_cmd = R, addr_sel = 1. others are waitstate values.  
`SLDR1 : controls = {3'b001,2'b0,5'b00010,3'b001,6'b0,3'b0}; //bsel = 1, loadc = 1
`SLDR2 : controls = {3'b001,2'b0,5'b0,3'b0,6'b000010,3'b0}; //load_addr = 1 to output values to the data address register
`SSTORE3 : controls = {3'b001,2'b0,5'b0,3'b0,6'b0,`W,1'b0}; // m_cmd = W, and addr_sel = 0
`SBLXX : controls = {3'b010,2'b0,5'b00100,3'b0,6'b0,3'b0}; //Take contents of RD and load into Rb    <---
`SLDR3 : controls = {3'b001,2'b0,5'b0,3'b0,6'b0,`R,1'b0}; //addr_sel = 0, m_cmd = R
`SLDR4 : controls = {3'b010,2'b11,5'b10000,3'b0,6'b0,3'b010}; //nsel = Rd, vsel = mdata, write = 1, write the input from the memory into Rd
  `SBL : controls = {3'b001,2'b01,5'b10000,3'b0,6'b0,3'b0}; //write is one, vsel = PC, nsel = Rn
 `SLOADR7 : controls = {3'b001,2'b0,5'b10000,3'b0,6'b0,3'b0};  //nsel = Rn, load contents of Rc into Rn,
 `SBLX : controls =  {3'b100,2'b0,5'b00010,3'b100,6'b0,3'b0};  //same as f, sets asel to 1, takes output of alu loads into c
`SSTORE : controls =   {3'b010,2'b0,5'b01000,3'b0,6'b0,3'b0}; //Take contents of RD and load into Ra
`SSTORE2 : controls = {3'b100,2'b0,5'b00010,3'b001,6'b0,3'b0}; //load Rc with bsel = 10
//assign {nsel,vsel,write,loada,loadb,loadc,loads,asel,bsel,pc_sel,load_pc,load_ir,load_addr,addr_sel,m_cmd} = controls;
`SHALT : begin 
	controls = {3'b001,2'b0,5'b0,3'b0,6'b0,2'b0,1'b1}; // Halt state which loops back to itself until reset is hit
	end
`SWHERE : controls = {3'b001,2'b0,5'b0,3'b0,6'b0,3'b0}; // Waiting state to let Instruciton REgister update before updating PC
`SUpdatePC : begin 
	    case({opcode,op,cond})
     //B
     8'b001xx000:  begin controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; end //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1
     //BEQ
     8'b001xx001:  begin if(Z == 1)
               controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1
                  else controls = {3'b001,2'b0,5'b0,3'b0,2'b0,4'b1001,`R,1'b0}; //pc_sel = 00, Set load_pc to 1, m_cmd to R, addr_sel to 1
      		end
	 //BNE
     8'b001xx010: begin if(Z == 0)
                controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1
               else controls = {3'b001,2'b0,5'b0,3'b0,2'b0,4'b1001,`R,1'b0}; //pc_sel = 00, Set load_pc to 1, m_cmd to R, addr_sel to 1
               end
	//BLT
     8'b001xx011: begin if(N != V)
                controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1
           	else controls = {3'b001,2'b0,5'b0,3'b0,2'b0,4'b1001,`R,1'b0}; //pc_sel = 00, Set load_pc to 1, m_cmd to R, addr_sel to 1
     		end
	//BLE
     8'b001xx100:begin  if((N != V) || (Z == 1))
               		controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1
               else controls = {3'b001,2'b0,5'b0,2'b00,2'b0,4'b1001,`R,1'b0}; //pc_sel = 00, Set load_pc to 1, m_cmd to R, addr_sel to 1
		end

     8'b010_11_111: begin controls = {3'b001,2'b0,5'b0,3'b0,2'b10,4'b1001,`R,1'b0}; end //Set load_pc to 1, m_cmd to R, pc_sel = branchjump, addr_sel to 1

     8'b010_00_000: begin  controls = {3'b001,2'b0,5'b0,3'b0,2'b11,4'b1001,`R,1'b0};  end//Set load_pc to 1, m_cmd to R, pc_sel = Rd, addr_sel to 1
           
     8'b010_10_111: begin  controls = {3'b001,2'b0,5'b0,3'b0,2'b11,4'b1001,`R,1'b0};  end//Set load_pc to 1, m_cmd to R, pc_sel = Rd, addr_sel to 1

default: begin controls = {3'b001,2'b0,5'b0,3'b0,2'b00,4'b1000,2'b0,1'b0};end //load_PC = 1. others are waitstate values (Normal update pc state conditions) 
    
	endcase	
  	     end //end the case 
default: controls = 22'bxxxxxxxxxxxxxxxxxxxxxx; 
endcase
end

//All the datapath controls are updated continously

//Only update the new state on the rising edgeo of the clock. 
always@(posedge clk) begin
presentS = next; 
{nsel,vsel,write,loada,loadb,loadc,loads,asel,bsel,pc_sel,load_pc,load_ir,load_addr,addr_sel,m_cmd,led8} = controls;
end

endmodule



