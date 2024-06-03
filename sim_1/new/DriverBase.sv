`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 06:03:47 PM
// Design Name: 
// Module Name: DriverBase
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
`ifndef INC_DRIVERBASE_SV
`define INC_DRIVERBASE_SV
int run_for_n_inss = 5;
int TRACE_ON = 1; //1 to fix error
class DriverBase;
    virtual RISCV_io.TB R_io; //interface signal
    string name; // unique identifier
    bit [31:0] ins;
    Instruction ins2send; // stimulus Instruction object
    event DONE_DRIVE;
    // show info :D
    extern function void display(input string prefix = "NOTE");
////    
    extern function new(input string name = "DriverBase", virtual RISCV_io.TB R_io);
    extern virtual task send();
endclass: DriverBase

function DriverBase::display(input string prefix = "NOTE");
    this.ins2send.display();
endfunction:display

function DriverBase::new(input string name = "DriverBase", virtual RISCV_io.TB R_io);
    if (TRACE_ON) $display("[TRACE]%t %s:%m", $realtime, name);
    this.name   = name;
    this.R_io   = R_io;
endfunction:new

task DriverBase::send();
    if (TRACE_ON) $display("[TRACE] SENDING %t %s:%m", $realtime, name);
    // SENDING HERE
    R_io.mem_ins <= ins;
endtask:send
`endif