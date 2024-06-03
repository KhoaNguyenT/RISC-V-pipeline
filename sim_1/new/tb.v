`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 11:58:27 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
    reg clk,rst;
    RISC_V_pipeline DUT(clk, rst);
    
    initial begin
        clk = 0;
        forever clk = #10~clk;
    end
    initial begin
        rst = 1;
        #30
        rst = 0;
        #300
        $finish();
    end 
endmodule
