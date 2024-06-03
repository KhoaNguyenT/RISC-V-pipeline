`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:47:41 AM
// Design Name: 
// Module Name: RISCV_test_top
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


module RISCV_test_top;
    parameter simulation_cycle = 20;
    bit SystemClock, reset_ne;
    bit [31:0] mem_ins_ne, PC_ne;
    RISCV_io top_io(SystemClock);
    Last_Test Run_RISCV(top_io.TB);
    assign reset_ne = top_io.reset;
    assign mem_ins_ne = top_io.mem_ins;
    assign PC_ne = top_io.PC;
    RISC_V_pipeline DUT(SystemClock, top_io.reset, top_io.mem_ins, top_io.PC);
    initial begin
        SystemClock = 0;
        forever begin 
            #(simulation_cycle/2) SystemClock = ~SystemClock;
        end
    end
endmodule
