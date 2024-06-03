`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:44:46 AM
// Design Name: 
// Module Name: RISCV_io
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


interface RISCV_io (input bit clock);
    logic reset;
    logic [31:0] mem_ins;
    logic [31:0] PC;  
    
    clocking cb @(posedge clock);
        default input #0 output #0;
        output reset;
        output mem_ins;
        input PC;
    endclocking: cb
    modport TB(clocking cb, output reset, output mem_ins, input PC);  
endinterface 
