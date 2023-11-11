`include "../define.v"
module WB #(
    parameter MEM22WB_WD = 50,
    parameter WB2ID_WD = 50
) (
    input wire clk, 
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [MEM22WB_WD-1:0] mem22wb_bus,
    output wire [WB2ID_WD-1:0] wb2id_fwd,

    output wire [63:0]  debug_wb_pc,
    output wire [7:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [63:0]  debug_wb_rf_wdata
);
    reg [MEM22WB_WD-1:0] mem22wb_bus_r;
    always @(posedge clk) begin
        if (!rst_n) begin
            mem22wb_bus_r <= 0;
        end
        else if (flush) begin
            mem22wb_bus_r <= 0;
        end
        else if (stall[6]&(!stall[7])) begin
            mem22wb_bus_r <= 0;
        end
        else if (!stall[6]) begin
            mem22wb_bus_r <= mem22wb_bus;
        end
    end

    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] rf_wdata;
    wire [63:0] pc;
    wire [31:0] inst;

    assign {
        rf_we,
        rf_waddr,
        rf_wdata,
        pc,
        inst
    } = mem22wb_bus_r;

    assign wb2id_fwd = {
        rf_we,
        rf_waddr,
        rf_wdata
    };

    assign debug_wb_pc = pc;
    assign debug_wb_rf_we = {8{rf_we}};
    assign debug_wb_rf_wnum = rf_waddr;
    assign debug_wb_rf_wdata = rf_wdata;
endmodule