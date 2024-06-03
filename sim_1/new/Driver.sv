`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 07:26:40 PM
// Design Name: 
// Module Name: Driver
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

`ifndef INC_DRIVER_SV
`define INC_DRIVER_SV
`include "DriverBase.sv"
`include "Instruction.sv"
class Driver extends DriverBase;
    bit [31:0] data [0:1023]; //
    extern function new(input string name, input virtual RISCV_io.TB R_io);
    extern virtual task start();
    extern function void display(input string prefix = "NOTE");
endclass: Driver

function Driver::new(input string name, input virtual RISCV_io.TB R_io);
    // Call base class constructor
    super.new(name, R_io);
    // Trace statement
    if (TRACE_ON) $display("[TRACE] new Driver operation  %t %s:%m", $realtime, name);
//    for(int i = 0; i <run_for_n_inss; i++) begin
    for (int i =0; i < run_for_n_inss; i++) begin
        data[i] = 32'd0;
    end
//    end
endfunction: new
task Driver::start();
     // Trace statement
     if (TRACE_ON) $display("[TRACE] %t %s: Starting Driver operation", $realtime, name);
     // Non-blocking fork-join block
     fork
        begin
            // Infinite loop
            while (1) begin
                if (R_io.PC !== 32'dx) begin
                    super.ins = data[R_io.PC];
                    this.send();
//                    continue;
                end
            repeat(1) @(R_io.cb);    
            end
//          i = i+1;
        end
     join_none 
endtask:start 
function void Driver::display(input string prefix = "NOTE");
    $display("\n%s Driver Info:", prefix,);
    super.display(prefix);
endfunction: display
`endif
