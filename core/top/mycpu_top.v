`include "../define.v"
module mycpu_top #(
    parameter IF12IF2_WD = 50,
    parameter IF22ID_WD = 50,
    parameter ID2EX_WD = 50,
    parameter EX2MEM1_WD = 50,
    parameter MEM12MEM2_WD = 50,
    parameter MEM22WB_WD = 50,

    parameter EX2ID_WD = 50,
    parameter MEM12ID_WD = 50,
    parameter MEM22ID_WD = 50,
    parameter WB2ID_WD = 50
) (
    input wire clk,
    input wire rst_n,

    output wire [63:0]  debug_wb_pc,
    output wire [7:0]   debug_wb_rf_we,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [63:0]  debug_wb_rf_wdata
);
    
    mycpu_pipeline 
    #(
        .IF12IF2_WD   (IF12IF2_WD   ),
        .IF22ID_WD    (IF22ID_WD    ),
        .ID2EX_WD     (ID2EX_WD     ),
        .EX2MEM1_WD   (EX2MEM1_WD   ),
        .MEM12MEM2_WD (MEM12MEM2_WD ),
        .MEM22WB_WD   (MEM22WB_WD   ),
        .EX2ID_WD     (EX2ID_WD     ),
        .MEM12ID_WD   (MEM12ID_WD   ),
        .MEM22ID_WD   (MEM22ID_WD   ),
        .WB2ID_WD     (WB2ID_WD     )
    )
    u_mycpu_pipeline(
    	.clk               (clk               ),
        .rst_n             (rst_n             ),
        .inst_sram_en      (inst_sram_en      ),
        .inst_sram_we      (inst_sram_we      ),
        .inst_sram_addr    (inst_sram_addr    ),
        .inst_sram_wdata   (inst_sram_wdata   ),
        .inst_sram_rdata   (inst_sram_rdata   ),
        .data_sram_en      (data_sram_en      ),
        .data_sram_we      (data_sram_we      ),
        .data_sram_addr    (data_sram_addr    ),
        .data_sram_wdata   (data_sram_wdata   ),
        .data_sram_rdata   (data_sram_rdata   ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_we    (debug_wb_rf_we    ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    
    bridge_1x3 u_bridge_1x3(
    	.clk             (clk             ),
        .resetn          (resetn          ),
        .cpu_data_en     (cpu_data_en     ),
        .cpu_data_we     (cpu_data_we     ),
        .cpu_data_addr   (cpu_data_addr   ),
        .cpu_data_wdata  (cpu_data_wdata  ),
        .cpu_data_rdata  (cpu_data_rdata  ),
        .data_sram_en    (data_sram_en    ),
        .data_sram_we    (data_sram_we    ),
        .data_sram_addr  (data_sram_addr  ),
        .data_sram_wdata (data_sram_wdata ),
        .data_sram_rdata (data_sram_rdata ),
        .clint_en        (clint_en        ),
        .clint_we        (clint_we        ),
        .clint_addr      (clint_addr      ),
        .clint_wdata     (clint_wdata     ),
        .clint_rdata     (clint_rdata     ),
        .axi_en          (axi_en          ),
        .axi_we          (axi_we          ),
        .axi_addr        (axi_addr        ),
        .axi_wdata       (axi_wdata       ),
        .axi_rdata       (axi_rdata       )
    );
    
    dual_port_ram_64 u_dual_port_ram_64(
    	.clka  (clka  ),
        .ena   (ena   ),
        .wea   (wea   ),
        .addra (addra ),
        .dina  (dina  ),
        .douta (douta ),
        .clkb  (clkb  ),
        .enb   (enb   ),
        .web   (web   ),
        .addrb (addrb ),
        .dinb  (dinb  ),
        .doutb (doutb )
    );
    
    clint u_clint(
    	.clk         (clk         ),
        .timer_clk   (timer_clk   ),
        .resetn      (resetn      ),
        .timer_int   (timer_int   ),
        .clint_en    (clint_en    ),
        .clint_we    (clint_we    ),
        .clint_addr  (clint_addr  ),
        .clint_wdata (clint_wdata ),
        .clint_rdata (clint_rdata )
    );
    
    
endmodule