`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 05:19:35 PM
// Design Name: 
// Module Name: Instruction
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
`ifndef INC_INSTRUCTION_SV
`define INC_INSTRUCTION_SV
//int TRACE_ON = 1;
//int run_for_n_inss = 10;
class Instruction;
    rand bit [6:0] Opcode;
    rand bit [4:0] Rs1, Rs2, Rd;
    rand bit [2:0] Funct3;
    rand bit [6:0] Funct7;
    string name;
    string convert;

//     Define Packet Property Constraints 
    constraint gen_ins {
        Opcode inside  {7'b0110011, // R-type
                        7'b0010011, // I-type
                        7'b0000011, // Load
                        7'b0100011, // Store
                        7'b1100011, // Branch
                        7'b1101111, // JAL
                        7'b1100111, // JALR
                        7'b0110111, // LUI
                        7'b0010111  // AUIPC
//                        7'b0000000 // NOPE
                        }; 
        Rs1 inside {[0:31]};
        Rs2 inside {[0:31]};
        Rd inside {[0:31]};
        Funct3 inside {[0:7]};
        Funct7 inside {[0:127]};  
        
        if (Opcode == 7'b0110011) {// R-type
            Funct3 inside {3'b000, // ADD, SUB
                           3'b001, // SLL        
                           3'b010, // SLT
                           3'b011, // SLTU
                           3'b100, // XOR
                           3'b101, // SRL, SRA
                           3'b110, // OR
                           3'b111  // AND
                           };
            if(Funct3 == 3'b000) {Funct7 inside{ 7'b0000000     // ADD
                                               , 7'b0100000};}  // SUB                
            if(Funct3 == 3'b101) {Funct7 inside{ 7'b0000000     // SRL
                                               , 7'b0100000};}  // SRA 
        }

        if (Opcode == 7'b0010011) {// I-type
            Funct3 inside {3'b000, // ADDI         
                           3'b010, // SLTI
                           3'b011, // SLTIU
                           3'b100, // XORI
                           3'b110, // ORI
                           3'b111, // ANDI
                           3'b001, // SLLI 
                           3'b101  // SRLI, SRAI
                           };
            if(Funct3 == 3'b001) {Funct7 inside{7'b0000000};}
            if(Funct3 == 3'b101) {Funct7 inside{ 7'b0000000     // SRLI
                                               , 7'b0100000};}  // SRAI     
        }       
        
        if (Opcode == 7'b0000011) {// Load
            Funct3 inside {3'b000, // LB
                           3'b001, // LH
                           3'b010, // LW
                           3'b100, // LBU
                           3'b101  // LHU
                           };
        }  
               
        if (Opcode == 7'b0100011) {// Store
            Funct3 inside {3'b000, // SB
                           3'b001, // SH
                           3'b010  // SW
                           };
        }
               
        if (Opcode == 7'b1100011) {// Branch
            Funct3 inside {3'b000, // BEQ
                           3'b001, // BNE
                           3'b100, // BLT
                           3'b101, // BGE
                           3'b110, // BLTU
                           3'b111  // BGEU
                           };
        }                            
    }//The value is bound from 37 commands
    
    // Define Instruction Class Method Prototypes 
    extern function new(input string name = "Ins");
    extern function void converting();
    extern function void display(input string prefix = "NOTE");
endclass:Instruction

function Instruction::new (input string name);
    this.name = name;
;
endfunction: new  
function void Instruction::converting();
     if (Opcode == 7'b0110011) begin // R-type
        if (Funct3 == 3'b000) begin
            if (Funct7 == 7'b0000000) convert = $sformatf("ADD");
            if (Funct7 == 7'b0100000) convert = $sformatf("SUB");
        end
        if (Funct3 == 3'b001) convert = $sformatf("SLL");
        if (Funct3 == 3'b010) convert = $sformatf("SLT");
        if (Funct3 == 3'b011) convert = $sformatf("SLTU");
        if (Funct3 == 3'b100) convert = $sformatf("XOR");
        if (Funct3 == 3'b101) begin
            if (Funct7 == 7'b0000000) convert = $sformatf("SRL");
            if (Funct7 == 7'b0100000) convert = $sformatf("SRA");
        end
        if (Funct3 == 3'b110) convert = $sformatf("OR");
        if (Funct3 == 3'b111) convert = $sformatf("AND");
        
        convert = $sformatf("%s x%d x%d x%d", convert, Rd, Rs1, Rs2);
    end
    if (Opcode == 7'b0010011) begin // I-type
        if (Funct3 == 3'b000) convert = $sformatf("ADDI");
        if (Funct3 == 3'b010) convert = $sformatf("SLTI");
        if (Funct3 == 3'b011) convert = $sformatf("SLTIU");
        if (Funct3 == 3'b100) convert = $sformatf("XORI");
        if (Funct3 == 3'b110) convert = $sformatf("ORI");
        if (Funct3 == 3'b111) convert = $sformatf("ANDI");
        if (Funct3 == 3'b001 && Funct7 == 7'b0000000) convert = $sformatf("SLLI");
        if (Funct3 == 3'b101) begin
            if (Funct7 == 7'b0000000) convert = $sformatf("SRLI");
            if (Funct7 == 7'b0100000) convert = $sformatf("SRLI");
        end
        convert = $sformatf("%s x%d x%d 0x%h", convert, Rd, Rs1, {Funct7,Rs2});
    end
    if (Opcode == 7'b0000011) begin // Load
        if (Funct3 == 3'b000) convert = $sformatf("LB");
        if (Funct3 == 3'b001) convert = $sformatf("LH");
        if (Funct3 == 3'b010) convert = $sformatf("LW");
        if (Funct3 == 3'b100) convert = $sformatf("LBU");
        if (Funct3 == 3'b101) convert = $sformatf("LHU");
        convert = $sformatf("%s x%d %h(x%d) ", convert, Rd, {Funct7,Rs2}, Rs1);
    end
    if (Opcode == 7'b0100011) begin // Store
        if (Funct3 == 3'b000) convert = $sformatf("SB");
        if (Funct3 == 3'b001) convert = $sformatf("SH");
        if (Funct3 == 3'b010) convert = $sformatf("SW");
        convert = $sformatf("%s x%d %h(x%d) ", convert, Rs2, {Funct7,Rd}, Rs1);
    end
    if (Opcode == 7'b1100011) begin // Branch
        if (Funct3 == 3'b000) convert = $sformatf("BEQ");
        if (Funct3 == 3'b001) convert = $sformatf("BNE");
        if (Funct3 == 3'b100) convert = $sformatf("BLT");
        if (Funct3 == 3'b101) convert = $sformatf("BGE");
        if (Funct3 == 3'b110) convert = $sformatf("BLTU");
        if (Funct3 == 3'b111) convert = $sformatf("BGEU");
        convert = $sformatf("%s x%d x%d 0x%h", convert, Rs1, Rs2, {Funct7[6],Rd[0], Funct7[5:0],Rd[4:1]});
    end
    if (Opcode == 7'b1101111) begin
        convert = $sformatf("JAL");
        convert = $sformatf("%s x%d 0x%h", convert, Rd, {Funct7[6], Rs1, Funct3, Rs2[0], Funct7[5:0], Rs2[4:1]});
    end
    if (Opcode == 7'b1100111) begin
        convert = $sformatf("JALR");
        convert = $sformatf("%s x%d 0x%h", convert, Rd, {Funct7, Rs2});
    end
    if (Opcode == 7'b0110111) begin
        convert = $sformatf("LUI");
        convert = $sformatf("%s x%d 0x%h", convert, Rd, {Funct7,Rs2,Rs1,Funct3});
    end
    if (Opcode == 7'b0010111) begin 
        convert = $sformatf("AUIPC");
        convert = $sformatf("%s x%d 0x%h", convert, Rd, {Funct7,Rs2,Rs1,Funct3});
    end
endfunction:converting

function void Instruction::display(input string prefix = "NOTE");
    if (TRACE_ON) $display("[TRACE]%t %s:%m", $realtime, name);
    $display("Instruction: %h",{this.Funct7[6:0], this.Rs2[4:0], this.Rs1[4:0], this.Funct3[2:0], this.Rd[4:0], this.Opcode[6:0]});
    this.converting();
    $display(convert);
    $display(this.Funct7[6]);
//    $display("OPCODE: %b", this.Opcode);
//    $display("RS1, RS2, RD: %b, %b, %b", this.Rs1,this.Rs2,this.Rd);
//    $display("Funct3: %b", this.Funct3);
//    $display("Funct7: %b", this.Funct7);
endfunction:display

typedef mailbox #(Instruction) ins_mbox;
`endif