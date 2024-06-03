`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:51:18 AM
// Design Name: 
// Module Name: Test
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


program automatic Test(RISCV_io.TB R_io);
     task reset();
        R_io.reset <= ~R_io.reset;
        $display ("Reset status");
     endtask:reset
     initial begin
        R_io.reset <= 1;
        repeat(1) @(R_io.cb);
        reset();
        repeat(12) @(R_io.cb);
        $display ("COMPLETED");
     end
endprogram 
