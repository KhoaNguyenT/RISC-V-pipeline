`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 05:15:28 PM
// Design Name: 
// Module Name: Last_Test
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


program automatic Last_Test (RISCV_io.TB R_io);
    int run_for_n_inss = 5;
    int TRACE_ON = 0; //1 to fix error
    `include "Instruction.sv"
    `include "Driver.sv"
    `include "Generator.sv"
    bit [31:0] data;
    Driver drvr;
    Generator ge;
    initial begin
        ge = new();
        ge.start();
        drvr = new("DRIVER",R_io);
        $display ("/////////////////COMPLETED GENERATION/////////////////");
        for (int i = 0; i < run_for_n_inss; i++) begin;
            data = ge.data[i];
            drvr.data[i*4] = data;
        end
        $display ("/////////////////COMPLETED CREATE INS/////////////////");
        R_io.reset <= 1;
        repeat(1) @(R_io.cb);
        reset();
        drvr.start();
        $display ("///////////////////COMPLETED DRIVE///////////////////");
        repeat(run_for_n_inss+4) @(R_io.cb);
        $display ("COMPLETED SIMULATION");
        $finish;
    end
    task reset();
        R_io.reset <= ~R_io.reset;
        $display ("Reset status");
    endtask:reset
endprogram: Last_Test
