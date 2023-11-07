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
    output wire [MEM12ID_WD-1:0] mem12id_fwd
);
    reg [EX2MEM1_WD-1:0] ex2mem1_bus_r;
    reg [63:0] data_sram_rdata_r;
    always @(posedge clk) begin
        if (!rst_n) begin
            ex2mem1_bus_r <= 0;
            data_sram_rdata_r <= 0;
        end
        else if (flush) begin
            ex2mem1_bus_r <= 0;
            data_sram_rdata_r <= 0;
        end
        else if (stall[4]&(!stall[5])) begin
            ex2mem1_bus_r <= 0;
            data_sram_rdata_r <= 0;
        end
        else if ((!stall[4])) begin
            ex2mem1_bus_r <= ex2mem1_bus;
            data_sram_rdata_r <= data_sram_rdata;
        end
    end

    wire [6:0] lsu_op;
    wire [3:0] data_size_sel;
    wire sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] ex_result;
    wire [31:0] pc;
    wire [31:0] inst;

    assign {
        lsu_op,
        data_ram_sel,
        sel_rf_res,
        rf_we,
        rf_waddr,
        ex_result,
        pc,
        inst
    } = ex2mem1_bus_r;

    assign mem12id_fwd = {
        rf_we,
        rf_waddr,
        ex_result
    };

    assign mem12mem2_bus = {
        data_sram_rdata_r,
        lsu_op,
        data_ram_sel,
        sel_rf_res,
        rf_we,
        rf_waddr,
        ex_result,
        pc,
        inst
    };


endmodule