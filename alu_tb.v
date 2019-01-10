module ALU_tb; 
  reg [15:0] Ain, Bin;
  reg [1:0] ALUop;
  wire [15:0] out;
  wire [2:0] nvz;
  reg err;

  ALU DUT(Ain,Bin,ALUop,out,nvz);

  //creates a checker to be called upon using the expected values of the output. 
  task my_checker;
    input [15:0] expected_out;
  begin
    //error messages get displayed when the expected output in not the same as actual output
    if(ALU_tb.DUT.out != expected_out) begin
      $display("ERROR: expected output is %b, actual is %b", expected_out, ALU_tb.DUT.out);
      err = 1'b1;
    end
  end
  endtask

  //creates a checker to be called upon using the expected values of the nvz output. 
  task my_checkerNVZ;
    input [2:0] expected_nvz;
  begin
    //error messages get displayed when the expected NVZ output in not the same as actual NVZ output
    if(ALU_tb.DUT.nvz != expected_nvz) begin
      $display("ERROR: expected nvzz is %b, actual is %b", expected_nvz, ALU_tb.DUT.nvz);
      err = 1'b1;
    end
  end
  endtask

  initial begin
    //initialise all values
    Ain = 16'b0000000000001010; Bin = 16'b0000000000000001;
    ALUop = 2'b00; err = 1'b0;
    #10;
    $display("Checking Ain + Bin");
    my_checker(16'b0000000000001011);
    
    ALUop = 2'b01;
    #10;
    $display("Checking Ain - Bin");
    my_checker(16'b0000000000001001);
    
    ALUop = 2'b10;
    #10;
    $display("Checking Ain & Bin");
    my_checker(16'b0000000000000000);
    
    ALUop = 2'b11;
    #10;
    $display("Checking ~Bin");
    my_checker(16'b1111111111111110);
    #10;

    //Check two numbers 16'd32760 and 16'd32 for overflow 
    Ain = 16'b0111111111111000; Bin = 16'b0000000000100000;
    #1;
    $display("Checking overflow 16'd32760 + 16'd32");
    my_checkerNVZ(3'b110);
    #10;
   
    //Check two numbers 16'd- 32760 and 16'd - 32 for overflow  
    Ain = 16'b1111111111111000; Bin = 16'b1000000001000000;
    #1;
    $display("Checking overflow 16'd-32760 + 16'd-32");
    my_checkerNVZ(3'b010);
    #10;

    if(err) $display("FAILED");
    else $display("PASSED");
    end
endmodule
