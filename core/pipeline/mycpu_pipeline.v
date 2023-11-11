`include "../define.v"
module mycpu_pipeline 
#(
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

    wire [IF12IF2_WD-1:0]   if12if2_bus;
    wire [IF22ID_WD-1:0]    if22id_bus;
    wire [ID2EX_WD-1:0]     id2ex_bus;
    wire [EX2MEM1_WD-1:0]   ex2mem1_bus;
    wire [MEM12MEM2_WD-1:0] mem12mem2_bus;
    wire [MEM22WB_WD-1:0]   mem22wb_bus;

    wire [EX2ID_WD-1:0]     ex2id_fwd;
    wire [MEM12ID_WD-1:0]   mem12id_fwd;
    wire [MEM22ID_WD-1:0]   mem22id_fwd;
    wire [WB2ID_WD-1:0]     wb2id_fwd;

    wire flush;
    wire [31:0] new_pc;
    wire [`StallBus-1:0] stall;
    wire stallreq_id;
    wire [32:0] br_bus;

    IF1 
    #(
        .IF12IF2_WD (IF12IF2_WD )
    )
    u_IF1(
    	.clk             (clk             ),
        .rst_n           (rst_n           ),
        .flush           (flush           ),
        .stall           (stall           ),
        .new_pc          (new_pc          ),
        .br_bus          (br_bus          ),
        .if12if2_bus     (if12if2_bus     ),
        .inst_sram_en    (inst_sram_en    ),
        .inst_sram_we    (inst_sram_we    ),
        .inst_sram_addr  (inst_sram_addr  ),
        .inst_sram_wdata (inst_sram_wdata )
    );

    IF2 
    #(
        .IF12IF2_WD (IF12IF2_WD ),
        .IF22ID_WD  (IF22ID_WD  )
    )
    u_IF2(
    	.clk             (clk             ),
        .rst_n           (rst_n           ),
        .flush           (flush           ),
        .stall           (stall           ),
        .br_bus          (br_bus          ),
        .inst_sram_rdata (inst_sram_rdata ),
        .if12if2_bus     (if12if2_bus     ),
        .if22id_bus      (if22id_bus      )
    );
    
    ID 
    #(
        .IF22ID_WD  (IF22ID_WD  ),
        .ID2EX_WD   (ID2EX_WD   ),
        .EX2ID_WD   (EX2ID_WD   ),
        .MEM12ID_WD (MEM12ID_WD ),
        .MEM22ID_WD (MEM22ID_WD ),
        .WB2ID_WD   (WB2ID_WD   )
    )
    u_ID(
    	.clk         (clk         ),
        .rst_n       (rst_n       ),
        .flush       (flush       ),
        .stall       (stall       ),
        .stallreq_id (stallreq_id ),
        .br_bus      (br_bus      ),
        .if22id_bus  (if22id_bus  ),
        .id2ex_bus   (id2ex_bus   ),
        .ex2id_fwd   (ex2id_fwd   ),
        .mem12id_fwd (mem12id_fwd ),
        .mem22id_fwd (mem22id_fwd ),
        .wb2id_fwd   (wb2id_fwd   )
    );
    
    
    EX 
    #(
        .ID2EX_WD   (ID2EX_WD   ),
        .EX2MEM1_WD (EX2MEM1_WD ),
        .EX2ID_WD   (EX2ID_WD   )
    )
    u_EX(
    	.clk             (clk             ),
        .rst_n           (rst_n           ),
        .flush           (flush           ),
        .stall           (stall           ),
        .br_bus          (br_bus          ),
        .id2ex_bus       (id2ex_bus       ),
        .ex2mem1_bus     (ex2mem1_bus     ),
        .ex2id_fwd       (ex2id_fwd       ),
        .data_sram_en    (data_sram_en    ),
        .data_sram_we    (data_sram_we    ),
        .data_sram_addr  (data_sram_addr  ),
        .data_sram_wdata (data_sram_wdata )
    );
    
    MEM1 
    #(
        .EX2MEM1_WD   (EX2MEM1_WD   ),
        .MEM12MEM2_WD (MEM12MEM2_WD ),
        .MEM12ID_WD   (MEM12ID_WD   )
    )
    u_MEM1(
    	.clk             (clk             ),
        .rst_n           (rst_n           ),
        .flush           (flush           ),
        .stall           (stall           ),
        .data_sram_rdata (data_sram_rdata ),
        .ex2mem1_bus     (ex2mem1_bus     ),
        .mem12mem2_bus   (mem12mem2_bus   ),
        .mem12id_fwd     (mem12id_fwd     )
    );
    
    MEM2 
    #(
        .MEM12MEM2_WD (MEM12MEM2_WD ),
        .MEM22WB_WD   (MEM22WB_WD   ),
        .MEM22ID_WD   (MEM22ID_WD   )
    )
    u_MEM2(
    	.clk           (clk           ),
        .rst_n         (rst_n         ),
        .flush         (flush         ),
        .stall         (stall         ),
        .mem12mem2_bus (mem12mem2_bus ),
        .mem22wb_bus   (mem22wb_bus   ),
        .mem22id_fwd   (mem22id_fwd   )
    );
    
    WB 
    #(
        .MEM22WB_WD (MEM22WB_WD ),
        .WB2ID_WD   (WB2ID_WD   )
    )
    u_WB(
    	.clk               (clk               ),
        .rst_n             (rst_n             ),
        .flush             (flush             ),
        .stall             (stall             ),
        .mem22wb_bus       (mem22wb_bus       ),
        .wb2id_fwd         (wb2id_fwd         ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_we    (debug_wb_rf_we    ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    

    ctrl u_ctrl(
    	.rst_n       (rst_n       ),
        .stallreq_id (stallreq_id ),
        .stall       (stall       )
    );

endmodule