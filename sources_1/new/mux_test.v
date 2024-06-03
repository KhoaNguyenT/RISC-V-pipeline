`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 12:38:00 AM
// Design Name: 
// Module Name: mux_test
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

module mux_test();
    reg sel;
    reg [31:0] ina, inb;
    wire [31:0] result;
    mux2_1 test(sel, ina, inb, result);
    initial begin
        ina = 32'b0;
        inb = 32'b1;
    end
endmodule
