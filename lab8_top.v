
`define MWRITE 2'b10
`define MREAD 2'b01
`define NONE 2'b00

module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  input CLOCK_50;
  output [9:0] LEDR;
  output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

  wire write, e, f,clk;
  wire [1:0] m_cmd;
  wire [8:0] mem_addr;
  wire [15:0] read_data, write_data,dout;
assign clk = CLOCK_50;
assign reset = ~KEY[1];
  //instatiate memory
  RAM MEM(clk,mem_addr[7:0],mem_addr[7:0],write,write_data,dout);

  //instatiate cpu
  cpu CPU(clk,reset,read_data,m_cmd,mem_addr,write_data,LEDR[8]);

  //instatiate tri state driver
  TSD triSD(m_cmd,mem_addr[8],dout,read_data,write);

  //switch circuits allow you to input data with switches when:
  assign e = (m_cmd == `MREAD)&&(mem_addr == 9'h140);
  //tri state driver that depends on e
  assign read_data[7:0] =  e ?SW[7:0]:8'bz;

  //led circuit outputs write_data[7:0] when:
  assign f = (m_cmd == `MWRITE)&&(mem_addr == 9'h100);
  //passes value through reg
  vRegLoadEnable #(8) ledReg(clk,f,write_data[7:0],LEDR[7:0]);

endmodule

module TSD(mem_cmd,mem_addr,dout,read_data,write);
  input [1:0] mem_cmd;
  input mem_addr;
  input [15:0] dout;
  output [15:0] read_data;
  output write;

  wire msel;
  //equality logic block to check if address is proper size for RAM
  assign msel = mem_addr == `NONE;
  //assign logic block to 
  assign write = msel && (`MWRITE == mem_cmd);
  //tri state driver
  assign read_data = (msel && (`MREAD == mem_cmd)) ? dout : 16'bz;

endmodule