`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// File Name: IntegerAlu.sv
//
// Name: Carson Holland
//
// Date: April 27th, 2023
// 
// File Purpose: The module for an integer ALU, capable of + - * / 64-bit integers
// 
// Assistance / Credit:


module IntegerAlu(Clk,IntDataOut,ExeDataOut, address, nRead,nWrite, nReset);

input logic Clk, nRead ,nWrite, nReset; //Inputs
input logic [15:0] address; 
input logic [255:0] ExeDataOut;
output logic [255:0] IntDataOut;

logic [7:0] operation; //Internal Variables
logic [255:0] alu_registers[5];

parameter source_1 = 0; //Internal INT Regs
parameter source_2 = 1;
parameter result = 2;
parameter status_in = 3;
parameter status_out = 4;

parameter ADD = 8'h10; //Integer ALU Opcodes
parameter SUB = 8'h11;
parameter MULT = 8'h12; 
parameter DIV = 8'h13;


assign operation = alu_registers[status_in];

always_comb begin
    if(nReset == 0) begin //If reset signal is low, reset all ALU regs
        alu_registers[source_1] = 256'h0;
        alu_registers[source_2] = 256'h0;
        alu_registers[result] = 256'h0;
        alu_registers[status_in] = 256'h0;
        alu_registers[status_out] = 256'h0;
    end
    
    if(address[15:12] == IntAluEn) begin //If top address is talking to the ALU
    
        if(nWrite == 0) begin //If write signal is low, we are writing to lower 12 bits of address -> reg
            alu_registers[address[11:0]] = ExeDataOut;
            alu_registers[status_out] = 0;
            end
            
        if(nRead == 0) //If reset signal is low, reset all ALU regs
            IntDataOut = alu_registers[address[11:0]];
    
    
    if (address[11:0] == 3) begin
    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the if address = intalu enable block~~~~~~~~~~~~~~~~~~~~~~~");
        case(operation)
            ADD: begin 
                    alu_registers[result] = alu_registers[source_1] + alu_registers[source_2];
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the add block~~~~~~~~~~~~~~~~~~~~~~~"); 
                    alu_registers[status_out] = 1;
                    end
            SUB: begin 
                    alu_registers[result] = alu_registers[source_1] - alu_registers[source_2];
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the sub block~~~~~~~~~~~~~~~~~~~~~~~"); 
                    alu_registers[status_out] = 1;
                    end
            MULT: begin 
                    alu_registers[result] = alu_registers[source_1] * alu_registers[source_2]; 
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the mult block~~~~~~~~~~~~~~~~~~~~~~~");
                    alu_registers[status_out] = 1;
                    end
            DIV: begin 
                    alu_registers[result] = alu_registers[source_2] / alu_registers[source_1]; 
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the div block~~~~~~~~~~~~~~~~~~~~~~~"); 
                    alu_registers[status_out] = 1;
                    end
            default: $display("I have hit the DEFAULT OF THE INT ALU CASE BLOCK");
            endcase
      end
    end

end

endmodule
