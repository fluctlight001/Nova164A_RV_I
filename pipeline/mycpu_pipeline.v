module mycpu_pipeline 
#(
    parameter ID2EX_WD = 50,
    parameter EX2MEM_WD = 50,
    parameter MEM2WB_WD = 50,
    parameter WB2RF_WD = 50,

    parameter MEM2EX_WD = 50,
    parameter WB2EX_WD = 50
)(
    input wire clk,
    input wire rst_n,

    output wire         inst_sram_en,
    output wire [7:0]   inst_sram_we,
    output wire [63:0]  inst_sram_addr,
    output wire [63:0]  inst_sram_wdata,
    input  wire [63:0]  inst_sram_rdata,

    output wire         data_sram_en,
    output wire [7:0]   data_sram_we,
    output wire [63:0]  data_sram_addr,
    output wire [63:0]  data_sram_wdata,
    input  wire [63:0]  data_sram_rdata,

    output wire [63:0]  debug_wb_pc,
    output wire [7:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [63:0]  debug_wb_rf_wdata
);

    
endmodule