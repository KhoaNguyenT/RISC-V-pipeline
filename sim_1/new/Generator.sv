`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 07:48:48 PM
// Design Name: 
// Module Name: Generator
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

`ifndef INC_GENERATOR_SV
`define INC_GENERATOR_SV
`include "Instruction.sv"
//int TRACE_ON = 1;
//int run_for_n_inss = 5;
class Generator;
    string  name;		// unique identifier
    Instruction  ins2send;	// stimulus object
    bit [31:0] data [0:1023];
    int count_time;
    
    extern function new(input string name = "Generator");
    extern function gen();
    extern virtual task start();
endclass: Generator

function Generator::new(input string name = "Generator");
    if (TRACE_ON) $display("[TRACE] new Generator operation:s %t %s:%m", $realtime, name);
    this.name = name;
    this.ins2send = new();
    this.count_time = 0;
endfunction: new 

function Generator::gen();
    static int inss_generated = 0;// Counter Generated packet
    if (TRACE_ON) $display("[TRACE]Gen operation: %t %s:%m", $realtime, name);
    ins2send.name = $sformatf("Ins[%0d]", inss_generated++);
    if (!ins2send.randomize()) begin //randomize() create rand bit
        $display("\n%m\n[ERROR]%t Randomization Failed!\n", $realtime);
        $finish;
    end
endfunction:gen

task Generator::start();
    // Trace statement
    if (TRACE_ON) $display("[TRACE] %t %s: Starting Generator operation", $realtime, name);
    // Non-blocking fork-join block
    fork
        begin
            // Infinite loop or loop for a specified number of packets
            for (int i = 0;run_for_n_inss <= 0 || i < run_for_n_inss; i++) begin
                // Call gen() to generate a Packet object
                gen();
                begin
                    //Instruction copyins = new();
                    Instruction copyins = new ins2send;
                    copyins.display();
                    // Deposit the copy of the Packet object into Drivers' out_box mailboxes
                    this.data[i] = {copyins.Funct7[6:0], copyins.Rs2[4:0], copyins.Rs1[4:0], copyins.Funct3[2:0],
                                    copyins.Rd[4:0], copyins.Opcode[6:0]}; 
                    $display("%b",this.data[i]);;
                end
            end
        end
    join
endtask: start
`endif

