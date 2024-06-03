module mux2_1
(
    input sel,
    input [31:0] ina, inb,
    output [31:0] result
);
    assign result = (sel == 1'b0) ? ina : inb;
endmodule

module mux3_1
(
    input [1:0] sel,
    input [31:0] ina, inb, inc,
    output [31:0] result
);
    assign result = (sel == 2'b00) ? ina : 
                    (sel == 2'b01) ? inb :
                    (sel == 2'b10) ? inc : 32'b0;
endmodule

 module adder
(
    input [31:0] ina, inb,
    output [31:0] result
);
    assign result = ina+inb;
endmodule

module PC
(
    input clk,rst,
    input [31:0] in,
    output reg [31:0] out
);
  always@(posedge clk) begin
    if(rst) out<=32'b0;
    else out<=in;
  end
endmodule

module IMEM
(
    input rst,
    input [9:0] addr,
    output reg [31:0] instruction
);
    reg [31:0] temp_mem [0:1023];
    initial $readmemh ("code.mem", temp_mem);
    always@(addr) begin
        if(rst) instruction = 32'b0;
        else instruction <= temp_mem[addr];
    end
    initial begin
        temp_mem[32'd0]     <= 32'h00000000; 
    end
endmodule

module registers
(
    input clk, rst, RegWEn,
    input [31:0] write_data,
    input [4:0] AddrA, AddrB, AddrD,
    output [31:0] DataA, DataB
);
    reg [31:0] register [0:31];
    always@(posedge clk) begin
        if (rst) register[AddrD] = 32'b0;
        else begin
            if(AddrD == 5'b0) register[AddrD] <= 32'b0;
            else 
                if (RegWEn) register[AddrD] <= write_data;
        end
    end
    assign DataA = register[AddrA];
    assign DataB = register[AddrB];  
    initial begin
     $readmemh("RegisterData.txt",register);
    end
endmodule

module imm_gen
(
    input [31:7] in,
    input [2:0] ImmSel,
    output reg [31:0] out
);
    always@(*) begin
        case(ImmSel)
            3'b000: out <= {{21{in[31]}}, in[30:20]}; // I-immediate
            3'b001: out <= {{21{in[31]}}, in[30:25], in[11:7]}; // S-immediate
            3'b010: out <= {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0}; // B-immediate
            3'b011: out <= {in[31], in[30:12], 12'b0}; // U-immediate
            3'b100: out <= {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0}; // J-immediate
            default: out <= 32'b0;
         endcase
     end
endmodule

module branchcomp 
(
    input [31:0] ina, inb,
    input brUn,
    output brLT,
    output brEQ
);
//    assign brLT = (brUn == 1) ? (ina < inb) : (brUn == 0) ?($signed(ina) < $signed(inb)) : 0;
//    assign brEQ = (brUn == 1) ? (ina == inb) : (brUn == 0) ?($signed(ina) == $signed(inb)) :0;
    assign brLT = (ina === 32'bx || inb === 32'bx) ?0: (brUn == 1) ? (ina < inb) : (brUn == 0) ?($signed(ina) < $signed(inb)) : 0;
    assign brEQ = (ina === 32'bx || inb === 32'bx) ?0: (brUn == 1) ? (ina == inb) : (brUn == 0) ?($signed(ina) == $signed(inb)) :0;
endmodule

module ALU
(
    input [31:0] ina, inb,
    input [3:0] ALUSel,
    output reg [31:0] result,
    output zero
);
    always@(*) begin
        case(ALUSel)
            4'b0000: result <= ina + inb; // add, addi, 5load, 3store, jal, jalr, auipc, beq, bne, bltu, bgeu, blt, bge
            4'b0001: result <= ina - inb; // sub
            4'b0010: result <= ina & inb; // and, andi
            4'b0011: result <= ina | inb; // or, ori
            4'b0100: result <= ina ^ inb; // xor, xori
            4'b0101: result <= ina << inb; // sll, slli
            4'b0110: result <= ina >> inb; // srl, srli
            4'b0111: result <= ina >>> inb; //sra, srai
            4'b1000: result <= (ina < inb) ? 32'b1 : 32'b0; // sltu, sltiu
            4'b1001: result <= ($signed(ina) < $signed(inb)) ? 32'b1 : 32'b0; // slt, slti
            4'b1010: result <= inb; //lui
            default: result <= 32'b0; 
        endcase
    end
    assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
endmodule

module ALUControl
(
    input [1:0] aluOp,
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] op,
    output reg [3:0] ALUinput
);
    always@(*) begin
        casex({aluOp, funct7[5], funct3})
            6'b00x000: ALUinput = 4'b0000; // lb, sb
            6'b00x001: ALUinput = 4'b0000; // lh, sh
            6'b00x010: ALUinput = 4'b0000; // lw, sw
            6'b00x100: ALUinput = 4'b0000; // lbu
            6'b00x101: ALUinput = 4'b0000; // lhu
            6'b100000: ALUinput = 4'b0000; // addi, add
            6'b101000: ALUinput = 4'b0001; // sub
            6'b10x111: ALUinput = 4'b0010; // and, andi
            6'b10x110: ALUinput = 4'b0011; // or, ori
            6'b10x100: ALUinput = 4'b0100; // xor, xori
            6'b100001: ALUinput = 4'b0101; // sll, slli
            6'b100101: ALUinput = 4'b0110; // srl, srli
            6'b101101: ALUinput = 4'b0111; // sra, srai
            6'b10x010: ALUinput = 4'b1000; // sltu, sltiu
            6'b100010: ALUinput = 4'b1001; // slt, slti
            6'b01xxxx: ALUinput = (op == 7'b0110111) ? 4'b1010 : 4'b0000; // lui, auipc, jal
            6'b01x000: ALUinput = 4'b0000; // jalr
            6'b11x000: ALUinput = 4'b0000; // beq 
            6'b11x001: ALUinput = 4'b0000; // bne
            6'b11x100: ALUinput = 4'b0000; // blt
            6'b11x101: ALUinput = 4'b0000; // bge
            6'b11x110: ALUinput = 4'b0000; // bltu
            6'b11x111: ALUinput = 4'b0000; // bgeu
        endcase
    end
endmodule

module DMEM
(
    input clk,memRW,// memRW = read/write (0/1)
    input [31:0] addr, dataW,
    output reg [31:0] dataR
);
    reg [31:0] memory [0:1023];
    always @(posedge clk) begin
        if(memRW == 1'b1) memory[addr] = dataW;
        else dataR = memory[addr]; 
    end 
endmodule

module controller
(
    input [6:0] opcode,
    input [2:0] funct3,
    output reg PCsel,
               RegWEn,
               Asel,
               Bsel,
               MemRW,
               BrUn,
    output reg [1:0] WBSel, ALUop,
    output reg [2:0] Immsel
);
    always@(opcode) begin
        if(opcode == 7'b0110011) begin // R-type
            PCsel = 1'b0;
            Immsel = 3'b000;
            RegWEn = 1'b1;
            Asel = 1'b0;
            Bsel = 1'b0;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b01;
            ALUop = 2'b10;
        end
        else if(opcode == 7'b0010011) begin // I-type
            PCsel = 1'b0;
            Immsel = 3'b000;
            RegWEn = 1'b1;
            Asel = 1'b0;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b01;
            ALUop = 2'b10;
        end
        else if(opcode == 7'b0000011) begin // Load
            PCsel = 1'b0;
            Immsel = 3'b000;
            RegWEn = 1'b1;
            Asel = 1'b0;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b00;
            ALUop = 2'b00;
        end
        else if(opcode == 7'b0100011) begin // Store
            PCsel = 1'b0;
            Immsel = 3'b001;
            RegWEn = 1'b0;
            Asel = 1'b0;
            Bsel = 1'b1;
            MemRW = 1'b1;
            BrUn = 1'bx;
            WBSel = 2'bxx;
            ALUop = 2'b00;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b000) begin // beq
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b1;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b001) begin // bne
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b0;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b100) begin // blt
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b0;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b101) begin // bge
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b0;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b110) begin // bltu
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b1;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b111) begin // bgeu
            PCsel = 0;
            Immsel = 3'b010;
            RegWEn = 1'b0;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'b1;
            WBSel = 2'bxx;
            ALUop = 2'b11;
        end
        else if(opcode == 7'b1101111) begin // jal
            PCsel = 1'b1;
            Immsel = 3'b100;
            RegWEn = 1'b1;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b10;
            ALUop = 2'b01;
        end
        else if(opcode == 7'b1100111) begin // jalr
            PCsel = 1'b1;
            Immsel = 3'b010;
            RegWEn = 1'b1;
            Asel = 1'b0;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b10;
            ALUop = 2'b01;
        end
        else if(opcode == 7'b0110111) begin // lui
            PCsel = 1'b0;
            Immsel = 3'b011;
            RegWEn = 1'b1;
            Asel = 1'bx;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b01;
            ALUop = 2'b01;
        end
        else if(opcode == 7'b0010111) begin // auipc
            PCsel = 1'b0;
            Immsel = 3'b011;
            RegWEn = 1'b1;
            Asel = 1'b1;
            Bsel = 1'b1;
            MemRW = 1'b0;
            BrUn = 1'bx;
            WBSel = 2'b01;
            ALUop = 2'b01;
        end
        else if(opcode == 7'b0000000) begin // NOPE
            PCsel = 1'b0;
            Immsel = 3'bx;
            RegWEn = 1'bx;
            Asel = 1'bx;
            Bsel = 1'bx;
            MemRW = 1'bx;
            BrUn = 1'bx;
            WBSel = 2'bx;
            ALUop = 2'bx;
        end
    end
endmodule

module IF
(
    input clk, rst, PCSel_MEM, IF_ID_EN,
    input [31:0] ALUResult_MEM, PC_IF, IMEM_IF,
    output reg [31:0] PC_ID, PC4_ID, IMEM_ID,
    output [31:0] mux_out
);
    wire [31:0] PC4_IF;
    wire [9:0] mem_addr = PC_IF[9:0];
//    PC pc_ifetch(clk, rst, mux_out, PC_IF);S
    adder a1(PC_IF, 32'h4, PC4_IF);
    mux2_1 mux_if(PCSel_MEM, PC4_IF, ALUResult_MEM, mux_out);
    always@(posedge clk) begin
        if(rst) begin
            PC_ID = 32'b0;
            IMEM_ID = 32'b0;
            PC4_ID = 32'b0;
        end
        else begin
            if(IF_ID_EN) begin
                PC_ID = PC_IF;
                IMEM_ID = IMEM_IF;
                PC4_ID = PC4_IF;
            end
        end
    end
endmodule

module ID
(
    input clk, rst, RegWEn_WB, ID_EX_EN,
    input [31:0] INSTRUCTION_ID, Data_D, PC_ID, PC4_ID,
    input [4:0] AddrWB,
    output reg [31:0] DataA_EX, DataB_EX, ImmOut_EX, PC_EX, PC4_EX,
    output reg BrEQ_EX, BrLT_EX,
    output reg [2:0] FUNCT3_EX,
    output reg [6:0] FUNCT7_EX, OPCODE_EX,
    output reg [4:0] AddrA_EX, AddrB_EX, AddrD_EX,
    //out controller
    output reg PCsel_EX, ASel_EX, BSel_EX, MemRW_EX, RegWEn_EX,
    output reg [1:0] WBSel_EX, ALUop_EX
);
    wire [2:0] FUNCT3 = INSTRUCTION_ID[14:12];
    wire [6:0] FUNCT7 = INSTRUCTION_ID[31:25];
    wire [6:0] OPCODE = INSTRUCTION_ID[6:0];
    wire [4:0] AddrD = INSTRUCTION_ID[11:7];
    wire [4:0] AddrA = INSTRUCTION_ID[19:15];
    wire [4:0] AddrB = INSTRUCTION_ID[24:20];
    wire [24:0] imm_in = INSTRUCTION_ID[31:7];
    wire BrUn, PCsel_ID, PCsel_out, ASel_ID, BSel_ID, MemRW_ID, RegWEn_ID;
    wire [1:0] ALUop_ID, WBSel_ID;
    wire [2:0] Immsel;
    wire [31:0] DataA_ID, DataB_ID, ImmOut_ID;
    wire BrEQ_ID, BrLT_ID;

    branchcomp brncmp(DataA_ID, DataB_ID, BrUn, BrLT_ID, BrEQ_ID);    
    controller Control(OPCODE, FUNCT3, PCsel_out, RegWEn_ID, ASel_ID, BSel_ID, MemRW_ID, BrUn, WBSel_ID, ALUop_ID, Immsel);
    registers reg_file(clk, rst, RegWEn_WB, Data_D, AddrA, AddrB, AddrWB, DataA_ID, DataB_ID);
    imm_gen imm(imm_in, Immsel, ImmOut_ID);
    assign PCsel_ID = PCsel_out | (BrLT_ID|0) | (BrEQ_ID|0);
    always @(posedge clk) begin
        if(rst) begin
            PCsel_EX = 1'b0;
            ASel_EX = 1'b0; 
            BSel_EX = 1'b0;
            MemRW_EX = 1'b0;
            WBSel_EX = 2'b0; 
            ALUop_EX = 2'b0;
            RegWEn_EX = 1'b0;
        end 
        else begin
            if(ID_EX_EN) begin
                PCsel_EX = PCsel_ID;
                ASel_EX = ASel_ID; 
                BSel_EX = BSel_ID;
                MemRW_EX = MemRW_ID;
                WBSel_EX = WBSel_ID; 
                ALUop_EX = ALUop_ID ;
                RegWEn_EX = RegWEn_ID;
            end
        end   
    end
    always  @(posedge clk) begin
        if(rst) begin
            DataA_EX = 32'd0;
            DataB_EX = 32'd0;
            ImmOut_EX = 32'd0;
            PC_EX = 32'd0;
            PC4_EX = 32'd0;
            BrEQ_EX = 1'd0;
            BrLT_EX = 1'd0;
            FUNCT3_EX = 3'd0;
            FUNCT7_EX = 7'd0;
            OPCODE_EX = 7'd0;
            AddrA_EX = 5'd0;
            AddrB_EX = 5'd0;
            AddrD_EX = 5'd0;
        end
        else begin
            if(ID_EX_EN) begin
                DataA_EX = DataA_ID;
                DataB_EX = DataB_ID;
                ImmOut_EX = ImmOut_ID;
                PC_EX = PC_ID;
                PC4_EX = PC4_ID;
                BrEQ_EX = BrEQ_ID;
                BrLT_EX = BrLT_ID;
                FUNCT3_EX = FUNCT3;
                FUNCT7_EX = FUNCT7;
                OPCODE_EX = OPCODE;
                AddrA_EX = AddrA;
                AddrB_EX = AddrB;
                AddrD_EX = AddrD;
            end
        end
    end
endmodule

module EX
(
    input clk, rst, EX_MEM_EN, ASel_EX, BSel_EX, MemRW_EX, RegWEn_EX, PCSel_EX,
    input [31:0] PC_EX, DataA_EX, DataB_EX, Imm_EX, PC4_EX, WB_Result,
    input [2:0] FUNCT3_EX,
    input [6:0] FUNCT7_EX, OPCODE_EX,
    input [1:0] WBSel_EX, ALUop_EX, ForwardAE, ForwardBE,
    input [4:0] AddrA_EX, AddrB_EX, AddrD_EX,
    output reg [31:0] ALUresult_MEM, PC4_MEM, DataW_MEM,
    output reg [4:0] AddrD_MEM,
    output zero_flag,
    output reg  MemRW_MEM, RegWEn_MEM, PCSel_MEM,
    output reg [1:0] WBSel_MEM
);
    
    wire [31:0] rs1_Data, rs2_Data;
    wire [3:0] ALUSel_EX;
    wire [31:0] outForwardAE, outForwardBE;
    wire [31:0]  ALUresult_From_MEM, ALUResult;
    
    ALUControl alu_control(ALUop_EX, FUNCT7_EX, FUNCT3_EX, OPCODE_EX, ALUSel_EX);
    mux3_1 mux31(ForwardAE, DataA_EX, WB_Result, ALUresult_From_MEM, outForwardAE);
    mux3_1 mux32(ForwardBE, DataB_EX, WB_Result, ALUresult_From_MEM, outForwardBE);
    mux2_1 muxrs1(ASel_EX, outForwardAE, PC_EX, rs1_Data);
    mux2_1 muxrs2(BSel_EX, outForwardBE, Imm_EX, rs2_Data);
    ALU ALU_EX(rs1_Data, rs2_Data, ALUSel_EX, ALUResult, zero_flag);
    assign ALUresult_From_MEM = ALUresult_MEM;
    always@(posedge clk) begin
        if(rst) begin
            ALUresult_MEM = 32'b0;
            PC4_MEM = 32'b0;
            DataW_MEM = 32'b0;
            AddrD_MEM = 5'b0;
        end
        else begin
            if(EX_MEM_EN) begin
                ALUresult_MEM = ALUResult;
                PC4_MEM = PC4_EX;
                DataW_MEM = outForwardBE;
                AddrD_MEM = AddrD_EX;
            end
        end
    end
    
    always@(posedge clk) begin
        if(rst) begin
            MemRW_MEM = 1'b0;
            WBSel_MEM = 2'b0;
            RegWEn_MEM = 1'b0;
            PCSel_MEM = 1'b0;
            
        end
        else begin
            if(EX_MEM_EN) begin
                MemRW_MEM = MemRW_EX;
                WBSel_MEM = WBSel_EX;
                RegWEn_MEM = RegWEn_EX;
                PCSel_MEM = PCSel_EX;
            end
        end
    end
endmodule

module MEM
(
    input clk, rst, MEM_WB_EN, MemRW_MEM, RegWEn_MEM,
    input [1:0] WBSel_MEM,
    input [31:0] ALUResult_MEM, DataW_MEM, PC4_MEM,
    input [4:0] AddrD_MEM,
    output reg [31:0] ALUResult_WB, DataR_WB, PC4_WB,
    output reg [4:0] AddrD_WB,
    output reg RegWEn_WB,
    output reg [1:0] WBSel_WB
);
    wire [31:0] DataR_MEM;
    DMEM DMEM_cycle(clk, MemRW_MEM, ALUResult_MEM, DataW_MEM, DataR_MEM);
    always@(posedge clk) begin
        if(rst) begin
            RegWEn_WB = 1'b0;
            WBSel_WB = 2'b0;
        end
        else begin
            if(MEM_WB_EN) begin
                RegWEn_WB = RegWEn_MEM;
                WBSel_WB = WBSel_MEM;
            end
        end
    end
    always@(posedge clk) begin
        if(rst) begin
            ALUResult_WB = 32'b0;
            DataR_WB = 32'b0;
            PC4_WB = 32'b0;
            AddrD_WB = 5'b0;
        end
        else begin
            if(MEM_WB_EN) begin
                ALUResult_WB = ALUResult_MEM;
                DataR_WB = DataR_MEM;
                PC4_WB = PC4_MEM;
                AddrD_WB = AddrD_MEM;
            end
        end
    end
endmodule

module WB
(
    input [1:0] WBSel_WB,
    input [31:0] ALUResult_WB, DataR_WB, PC4_WB,
    output [31:0] WB_Result
);
    mux3_1 write_back(WBSel_WB, DataR_WB, ALUResult_WB, PC4_WB, WB_Result);
endmodule

module hazard_unit
(
    input RegWEn_MEM, RegWEn_WB,
    input [4:0] AddrA_EX, AddrB_EX, AddrD_MEM, AddrD_WB,
    output [1:0] forwardAE, forwardBE
);
    assign forwardAE = (RegWEn_MEM == 1 && AddrD_MEM != 0 && AddrD_MEM == AddrA_EX) ? 2'b10 : 
                       (RegWEn_WB == 1 && AddrD_WB != 0 && AddrD_WB == AddrA_EX) ? 2'b01 : 2'b00;
    assign forwardBE = (RegWEn_MEM == 1 && AddrD_MEM != 0 && AddrD_MEM == AddrB_EX) ? 2'b10 : 
                       (RegWEn_WB == 1 && AddrD_WB != 0 && AddrD_WB == AddrB_EX) ? 2'b01 : 2'b00;
endmodule


module RISC_V_pipeline
(
    input clk, rst,
    input [31:0] mem_ins,
    output [31:0] PC_IF
);
    wire PC_write, ImmSel, RegWEn_WB, BrEQ_EX, BrLT_EX, ASel_EX, BSel_EX, MemRW_EX, 
         RegWEn_EX, zero_flag,MemRW_MEM, RegWEn_MEM, PCSel_EX, PCSel_MEM;
    wire [1:0] WBSel_EX, ALUop_EX, WBSel_MEM, ForwardAE, ForwardBE, WBSel_WB;
    wire [2:0] FUNCT3_EX;
    wire [4:0] AddrWB, AddrA_EX, AddrB_EX, AddrD_EX, AddrD_MEM, AddrD_WB;
    wire [6:0] FUNCT7_EX, OPCODE_EX;
    wire [31:0] PC_ID, IMEM_ID, PC4_ID, DataA_EX, DataB_EX, ImmOut_EX, PC_EX, PC4_EX, mux_out,
                WB_Result, ALUresult_MEM, PC4_MEM, DataW_MEM, ALUResult_WB, DataR_WB, PC4_WB;
    parameter IF_ID_EN = 1'b1;
    parameter ID_EX_EN = 1'b1;
    parameter EX_MEM_EN = 1'b1;
    parameter MEM_WB_EN = 1'b1;
    PC pc_ifetch(clk, rst, mux_out, PC_IF);
    
    IF Fetch(clk, rst, PCSel_MEM, IF_ID_EN, ALUresult_MEM, PC_IF, mem_ins, PC_ID, PC4_ID, IMEM_ID, mux_out);
  
    ID Decode(clk, rst, RegWEn_WB, ID_EX_EN, IMEM_ID, WB_Result, PC_ID, PC4_ID, AddrD_WB,
              DataA_EX, DataB_EX, ImmOut_EX, PC_EX, PC4_EX, BrEQ_EX, BrLT_EX, FUNCT3_EX, FUNCT7_EX, OPCODE_EX,
              AddrA_EX, AddrB_EX, AddrD_EX, PCSel_EX, ASel_EX, BSel_EX, MemRW_EX, RegWEn_EX, WBSel_EX, ALUop_EX);
              
    EX Execute(clk, rst, EX_MEM_EN, ASel_EX, BSel_EX, MemRW_EX, RegWEn_EX, PCSel_EX, PC_EX, DataA_EX, DataB_EX, ImmOut_EX,
               PC4_EX, WB_Result, FUNCT3_EX, FUNCT7_EX, OPCODE_EX, WBSel_EX, ALUop_EX, ForwardAE, ForwardBE,
               AddrA_EX, AddrB_EX, AddrD_EX, ALUresult_MEM, PC4_MEM, DataW_MEM, AddrD_MEM, zero_flag, MemRW_MEM, RegWEn_MEM, PCSel_MEM, WBSel_MEM);
               
    MEM Memory(clk, rst, MEM_WB_EN, MemRW_MEM, RegWEn_MEM, WBSel_MEM, ALUresult_MEM, DataW_MEM, PC4_MEM, AddrD_MEM, ALUResult_WB, DataR_WB, PC4_WB, AddrD_WB, RegWEn_WB, WBSel_WB);
    
    WB WriteBack(WBSel_WB, ALUResult_WB, DataR_WB, PC4_WB, WB_Result);
    
    hazard_unit HZ(RegWEn_MEM, RegWEn_WB, AddrA_EX, AddrB_EX, AddrD_MEM, AddrD_WB, ForwardAE, ForwardBE);
endmodule



