// File Name: ExecutionEngine.sv
//
// Name: Carson Holland
//
// Date: April 27th, 2023
// 
// File Purpose: Execution enigne to control data flow of a simple processor
// 
// Assistance / Credit: 

//Top Nibble of Addressing to Modules
parameter MainMemEn = 0;
parameter InstrMemEn = 1;
parameter MatrixAluEn = 2;
parameter IntAluEn = 3;
parameter RegisterEn = 4;
parameter ExecuteEn = 5;

module Execution(Clk,InstructDataOut,MemDataOut,MatrixDataOut,IntDataOut,ExeDataOut, address, nRead,nWrite, nReset);

input logic Clk, nReset; //Control Signals
input logic [31:0] InstructDataOut; //Instruction Input
input logic [255:0] MemDataOut, IntDataOut, MatrixDataOut;

output logic [255:0] ExeDataOut; //Outputs
output logic [15:0] address;
output logic nRead, nWrite;

//Internal Regs / logic
logic [31:0] instruction;
logic [7:0] opcode;
logic [255:0] execution_registers[5];
logic [15:0] PC;
parameter source_1 = 0;
parameter source_2 = 1;
parameter result = 2;
parameter status_in = 3;
parameter status_out = 4;

logic [255:0] general_registers[5];

//States Enumeration
enum {read_instruction, 
      read_instruction_data, 
      decode_instruction,
      find_source_1,
      get_source_1,
      find_dest_source_1,
      move_source_1,
      finish_move_1,
      find_source_2,
      move_imm,
      get_source_2,
      find_dest_source_2,
      move_source_2,
      finish_move_2,
      do_math,
      wait_result,
      finish_math,
      read_result,
      move_result,
      result_finish} state, next_state;

//Opcode Parameters
parameter stop = 8'hff;


always_ff @ (negedge Clk or negedge nReset) begin
    if(~nReset) begin //If we reset, go back to the first state and make the PC 0
        state <= read_instruction;
        execution_registers[source_1] = 0;
        execution_registers[source_2] = 0;
        execution_registers[result] = 0;
        PC = 0;
    end
    else //If we are not resetting, our state will be the next state
        state <= next_state;
end //Always_FF end

always_comb begin
    if(nReset) begin //Only do the logic is reset is not active
        case(state)
            read_instruction: begin //FIRST STATE. Grab the intruction that's next
                address[15:12] = InstrMemEn;
                address[11:0] = PC;
                nRead = 0;
                next_state = read_instruction_data;
        
            end// Read_instruction case end
            
            read_instruction_data: begin
                instruction = InstructDataOut; //Our current instruction is equal to instructionROM's data out
                opcode = instruction[31:24];
                nRead = 1;
                next_state = decode_instruction;
            end //Read instruction data end
            
            decode_instruction: begin
                if(opcode == stop) 
                    $finish;
                else
                    next_state = find_source_1;
            end //Decode instruction end
            
            find_source_1: begin
                if(instruction[15:12] == MainMemEn) //Bits 15-12 of instruction are mem/reg for source 1
                    address[15:12] = MainMemEn; //The upper nibble of the source1, main memory or reg
                else
                    address[15:12] = RegisterEn;
                address[11:0] = instruction[11:8]; //Lower nibble of source 1, where in main memory of reg
                nRead = 0;
                next_state = get_source_1;
            end// find source 1 end
            
            get_source_1: begin
                if(instruction[15:12] == MainMemEn) //Bits 15-12 of instruction are mem/reg for source 1
                    execution_registers[source_1] = MemDataOut; //The upper nibble of the source1, main memory or reg
                else
                    execution_registers[source_1] = general_registers[address[11:0]];
                 //BAD DESIGN COULD BE REGS
                next_state = find_dest_source_1;
            end //Integer get source 1 end
            
            find_dest_source_1: begin
                if(opcode[7:4] == 0) begin
                    $display("Opcode upper nibble == 0");
                    address[15:12] = MatrixAluEn;
                    end
                if (opcode[7:4] == 1)begin 
                    $display("OPCode upper nibble == 1");
                    address[15:12] = IntAluEn;
                    end
                address[11:0] = 0; //Address for source 1 in integer alu and matrix alu
                ExeDataOut = execution_registers[source_1];
                next_state = move_source_1;
            end //find dest source1 end 
            
            move_source_1: begin
                nWrite = 0;
                next_state = finish_move_1;
            end //Intmove source1 end 
            
            finish_move_1: begin
                nRead = 1;
                nWrite = 1;
                next_state = find_source_2;
            end
            
            find_source_2: begin
                if(opcode == 8'h07) //If opcode refers to an imm instruction, skip finding source 2 logic
                    next_state = move_imm;
                else begin
                    if(instruction[7:4] == 4'h0) //Bits 15-12 of instruction are mem/reg for source 1
                        address[15:12] = MainMemEn; //The upper nibble of the source1, main memory or reg
                    else
                        address[15:12] = RegisterEn;
                    address[11:0] = instruction[3:0]; //Lower nibble of source 2
                    nRead = 0;
                    next_state = get_source_2;
                end
            end// find source 2 end
            
            move_imm: begin
                ExeDataOut = instruction[7:0];
                address[11:0] = 1; //Last 8 bits are the imm
                next_state = move_source_2;
            end
                   
            get_source_2: begin
                if(address[15:12] == MainMemEn)
                    execution_registers[source_2] = MemDataOut; //BAD DESIGN COULD BE REGS  
                else
                    execution_registers[source_2] = general_registers[address[11:0]];
                next_state = find_dest_source_2;  
            end //Integer get source 1 end
            
             find_dest_source_2: begin
                if(opcode[7:4] == 0)
                    address[15:12] = MatrixAluEn;
                if (opcode[7:4] == 1)
                    address[15:12] = IntAluEn;
                address[11:0] = 1; //Address for source 2 in integer alu and matrix alu
                ExeDataOut = execution_registers[source_2];
                next_state = move_source_2;
            end //find dest source1 end 
            
            move_source_2: begin
                nWrite = 0;
                next_state = finish_move_2;
            end //Intmove source2 end 
            
            finish_move_2: begin
                nRead = 1;
                nWrite = 1;
                next_state = do_math;
            end
            
            do_math: begin
                if(opcode[7:4] == 0)
                    address[15:12] = MatrixAluEn;
                else if (opcode[7:4] == 1)
                    address[15:12] = IntAluEn;
                address[11:0] = 3; //this is status in index
                ExeDataOut = opcode;
                nWrite = 0;
                next_state = wait_result;
            end //Do math end
            
            wait_result: begin
                nWrite = 1;
                address[11:0] = 4; //Status Out register index
                nRead = 0;
                if(address[15:12] == MatrixAluEn) begin
                    if(MatrixDataOut == 256'h0) next_state = wait_result;
                    else if (MatrixDataOut == 256'h1) next_state = finish_math; 
                end
                
                if(address[15:12] == IntAluEn) begin
                    if(IntDataOut == 0) next_state = wait_result;
                    else if(IntDataOut == 1) next_state = finish_math; 
                end
            end//Wait result end
            
            finish_math: begin
                address[11:0] = 2; //2 Is the index for the result registers in INT and MATRIX Alu's
                nRead = 0;
                next_state = read_result;
            end
            
            read_result: begin
                 
                if(opcode[7:4] == 0)
                    execution_registers[result] = MatrixDataOut;
                else if (opcode[7:4] == 1)
                    execution_registers[result] = IntDataOut;     
                next_state = move_result;
            end //Move result end
            
            move_result: begin
                if(instruction[23:20] == 0) begin //Bits 23-20 is the destination Reg/Mem nibble
                    address[15:12] = MainMemEn;
                    address[11:0] = instruction[19:16]; //Bottom nibble of the destination field 
                    ExeDataOut = execution_registers[result];
                    nWrite = 0;
                    end
                else //If the destination is not main memmory, it is an internal register
                    general_registers[instruction[19:16]] = execution_registers[result];     
                next_state = result_finish;
            end //move result finish
            
            result_finish: begin
                nRead = 1;
                nWrite = 1;
                PC = PC + 1;
                next_state = read_instruction;
            end//Move resultfinish
    
    
            default: $display("The  default case of the execution module is hit!");
    endcase //State machine end case
    end //If nreset end

end //always comb end




endmodule
