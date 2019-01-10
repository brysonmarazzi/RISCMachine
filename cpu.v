//Module that puts all new modules together such as FSM, decoder, and updated datapath. 
module cpu(clk,reset,in,m_cmd,mem_addr,DPout,led8);
input clk,reset;
input [15:0] in;
output [1:0] m_cmd; 
output [8:0] mem_addr; 
output [15:0] DPout; 
output led8;
wire N,V,Z;

//Controls for datapath and decoder. 
wire write,loada,loadb,loadc,loads,asel,load_ir,load_pc,addr_sel,load_addr;
wire [1:0] pc_sel,bsel; //lab 7
wire [2:0] nsel, opcode,readnum, writenum,cond;
wire [1:0] ALUop,op,shift,vsel;
wire [15:0] sximm5, sximm8, iRout, DPout;
wire [8:0] next_pc,addOut,PC,pc_branch; 



//Instruction register to control flow of data into all other modules
vRegLoadEnable instructionRegister(clk,load_ir,in,iRout);

//register for program counter that has the address of the memory we want to access
vRegLoadEnable #(9) programCounter(clk,load_pc,next_pc,PC);

//register that stores the memory address for writing data?
vRegLoadEnable #(9) dataAddress(clk,load_addr,DPout[8:0],addOut);

//instruction decoder to break up input and output values to finite state machine and datapath
instructionDecoder DECODER(iRout, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum,cond);

//Finite State Machine to output all controls for datapath that are not sent fron decoder.
// Controls the cycles to perform an instruction. Outputs w = 1 when state is the waiting state. 
FSM FSM(clk,reset,cond,N,V,Z,opcode,op,nsel,vsel,write,loada,loadb,loadc,loads,asel,bsel,pc_sel,load_pc,load_ir,load_addr,addr_sel,m_cmd,led8);
    
//The flow of data which manipulates inputs and loads registers. Outputs output for CPU. 
datapath DP(clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads
		,writenum,write,sximm5,in,sximm8,PC[7:0],DPout,N,V,Z);

assign pc_branch = sximm8 + PC + 1'b1;

mux3 pcMux(PC+1'b1,9'b0,pc_branch,DPout[8:0],pc_sel,next_pc);
 
//mux's and logic blocks for program counter 
//assign next_pc = reset_pc ? 9'b0 : PC + 1;

assign mem_addr = addr_sel ? PC : addOut;

//assign led8 = (in[15:13] !== 3'b111) ? 1'b0 : 1'b1; 

endmodule


//2 bit binary select 4 input mux
module mux3(a0,a1,a2,a3,asel,out);
input [8:0] a1,a0,a2,a3; //Inputs 
input [1:0] asel;
output [8:0] out;
reg [15:0] outTemp; 
always@(*) begin
case(asel)
2'b00 : outTemp = a0;
2'b01 : outTemp = a1; 
2'b10 : outTemp = a2;
2'b11 : outTemp = a3;
endcase
end
assign out = outTemp;
endmodule

