`include "define.v"
module MEM1 #(
    parameter EX2MEM1_WD = 50,
    parameter MEM12MEM2_WD = 50,
    parameter MEM12ID_WD = 50
) (
    input wire clk, 
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [63:0] data_sram_rdata,

    input wire [EX2MEM1_WD-1:0] ex2mem1_bus,
    output wire [MEM12MEM2_WD-1:0] mem12mem2_bus,
);
    
endmodule