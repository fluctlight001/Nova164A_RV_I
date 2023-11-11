//*************************************************************************
//   > File Name   : bridge_1x3.v
//   > Description : bridge between cpu_data and data ram, clint
//   
//     master:        cpu_data
//                    /   |   \
//     1 x 2         /    |    \  
//     bridge:      /     |     \                    
//                 /      |      \       
//     slave: data_ram clint  axi_ctrl
//
//   > Author      : rt_Ni
//   > Date        : 2022-12-10
//*************************************************************************
`define CLINT_ADDR_BASE 16'h0200 // 32'h0200_xxxx
`define DEV_ADDR_BASE   16'ha000 // 32'h1000_xxxx
`define IO_ADDR_BASE    16'h1004 // 32'h1004_xxxx
// `define CONF_ADDR_MASK  16'hffff
module bridge_1x3(                                 
    input                           clk,          // clock 
    input                           resetn,       // reset, active low
    // master : cpu data
    input                           cpu_data_en,      // cpu data access enable
    input  [7                   :0] cpu_data_we,      // cpu data write byte enable
    input  [63                  :0] cpu_data_addr,    // cpu data address
    input  [63                  :0] cpu_data_wdata,   // cpu data write data
    output [63                  :0] cpu_data_rdata,   // cpu data read data
    // slave : data ram 
    output                          data_sram_en,     // access data_sram enable
    output [7                   :0] data_sram_we,     // write enable 
    output [63                  :0] data_sram_addr,   // address
    output [63                  :0] data_sram_wdata,  // data in
    input  [63                  :0] data_sram_rdata,  // data out
    // slave : clint 
    output                          clint_en,         // access clint enable 
    output [7                   :0] clint_we,         // access clint enable 
    output [63                  :0] clint_addr,       // address
    output [63                  :0] clint_wdata,      // write data
    input  [63                  :0] clint_rdata,      // read data

    output                          axi_en,
    output [7                   :0] axi_we,
    output [63                  :0] axi_addr,
    output [63                  :0] axi_wdata,
    input  [63                  :0] axi_rdata
);
    wire sel_sram;   // cpu data is from data ram
    wire sel_clint;  // cpu data is from clint
    wire sel_axi;    // cpu data is from axi

    reg sel_sram_r;  // reg of sel_dram 
    reg sel_clint_r; // reg of sel_clint 
    reg sel_axi_r;   // reg of sel_axi

    assign sel_clint = (cpu_data_addr[31:16] == `CLINT_ADDR_BASE);
    assign sel_axi   = (cpu_data_addr[31:16] == `DEV_ADDR_BASE) || (cpu_data_addr[31:16] == `IO_ADDR_BASE); 
    assign sel_sram  = ~sel_clint & ~sel_axi;

    // data sram
    assign data_sram_en    = cpu_data_en & sel_sram;
    assign data_sram_we    = cpu_data_we & {8{sel_sram}};
    assign data_sram_addr  = cpu_data_addr;
    assign data_sram_wdata = cpu_data_wdata;

    // clint
    assign clint_en    = cpu_data_en & sel_clint;
    assign clint_we    = cpu_data_we & {8{sel_clint}};
    assign clint_addr  = cpu_data_addr;
    assign clint_wdata = cpu_data_wdata;

    // axi
    assign axi_en    = cpu_data_en & sel_axi;
    assign axi_we    = cpu_data_we & {8{sel_axi}};
    assign axi_addr  = cpu_data_addr;
    assign axi_wdata = cpu_data_wdata;

    always @ (posedge clk)
    begin
        if (!resetn)
        begin
            sel_sram_r  <= 1'b0;
            sel_clint_r <= 1'b0;
            sel_axi_r   <= 1'b0;
        end
        else
        begin
            sel_sram_r  <= sel_sram;
            sel_clint_r <= sel_clint;
            sel_axi_r   <= sel_axi;
        end
    end

    assign cpu_data_rdata   = {64{sel_sram_r}}  & data_sram_rdata
                            | {64{sel_clint_r}} & clint_rdata
                            | {64{sel_axi_r}}   & axi_rdata;

endmodule

