`include "define.v"
module ID #(
    parameter IF22ID_WD = 50,
    parameter ID2EX_WD = 50,
    parameter EX2ID_WD = 50,
    parameter MEM12ID_WD = 50,
    parameter MEM22ID_WD = 50,
    parameter WB2ID_WD = 50
)(
    input wire clk, 
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [32:0] br_bus,

    input wire [IF22ID_WD-1:0] if22id_bus,
    output wire [ID2EX_WD-1:0] id2ex_bus,

    input wire [EX2ID_WD-1:0] ex2id_fwd,
    input wire [MEM12ID_WD-1:0] mem12id_fwd,
    input wire [MEM22ID_WD-1:0] mem22id_fwd,
    input wire [WB2ID_WD-1:0] wb2id_fwd
);
    reg [IF22ID_WD-1:0] if22id_bus_r;
    wire br_e;
    wire [31:0] br_addr;
    assign {br_e, br_addr} = br_bus;
    wire [31:0] inst;
    wire [31:0] pc;
    wire pc_valid;

    always @(posedge clk) begin
        if (!rst_n) begin
            if22id_bus_r <= 0;
        end
        else if (flush) begin
            if22id_bus_r <= 0;
        end
        else if (stall[2]&(!stall[3])) begin
            if22id_bus_r <= 0;
        end
        else if ((!stall[2])&br_e) begin
            if22id_bus_r <= 0;
        end
        else if ((!stall[2])) begin
            if22id_bus_r <= if22id_bus;
        end
    end

    assign {inst, pc_valid, pc} = if22id_bus_r;

    wire [1:0] sel_src1;
    wire sel_src2;
    wire [3:0] sel_rf_res;
    wire [14:0] alu_op;
    wire [7:0] bru_op;
    wire [6:0] lsu_op;
    wire [4:0] mul_op;
    wire [3:0] div_op;

    // csr instruction
    wire [3:0] csr_op;
    wire [11:0] csr_addr;
    wire csr_wdata_sel;  // select the imm
    wire [63:0] csr_wdata;
    wire [63:0] csr_vec;
    wire [31:0] csr_vec_l;
    wire rf_we;

    wire [4:0] rs1, rs2;
    wire [63:0] rdata1, rdata2;
    wire [63:0] imm;
    wire [4:0] rf_waddr;

    wire        ex_rf_we,    mem1_rf_we,    mem2_rf_we,    wb_rf_we;
    wire [4:0]  ex_rf_waddr, mem1_rf_waddr, mem2_rf_waddr, wb_rf_waddr;
    wire [63:0] ex_rf_wdata, mem1_rf_wdata, mem2_rf_wdata, wb_rf_wdata;

    decoder_64i u_decoder_64i(
    	.inst          (inst          ),
        .sel_src1      (sel_src1      ),
        .sel_src2      (sel_src2      ),
        .rs1           (rs1           ),
        .rs2           (rs2           ),
        .imm           (imm           ),
        .alu_op        (alu_op        ),
        .bru_op        (bru_op        ),
        .lsu_op        (lsu_op        ),
        .mul_op        (mul_op        ),
        .div_op        (div_op        ),
        .csr_op        (csr_op        ),
        .csr_addr      (csr_addr      ),
        .csr_wdata_sel (csr_wdata_sel ),
        .csr_vec_l     (csr_vec_l     ),
        .sel_rf_res    (sel_rf_res    ),
        .rf_we         (rf_we         ),
        .rf_waddr      (rf_waddr      )
    );

    regfile u_regfile(
    	.clk    (clk    ),
        .rst_n  (rst_n  ),
        .rs1    (rs1    ),
        .rdata1 (rdata1 ),
        .rs2    (rs2    ),
        .rdata2 (rdata2 ),
        .we     (we     ),
        .waddr  (waddr  ),
        .wdata  (wdata  )
    );

    wire [63:0] src1, src2;
    assign src1 = ex_rf_we & (ex_rf_waddr == rs1) & (|rs1) ? ex_rf_wdata
                : mem1_rf_we & (mem1_rf_waddr == rs1) & (|rs1) ? mem1_rf_wdata
                : mem2_rf_we & (mem2_rf_waddr == rs1) & (|rs1) ? mem2_rf_wdata
                : wb_rf_we & (wb_rf_waddr == rs1) & (|rs1) ? wb_rf_wdata
                : rdata1;
    assign src2 = ex_rf_we & (ex_rf_waddr == rs2) & (|rs2) ? ex_rf_wdata
                : mem1_rf_we & (mem1_rf_waddr == rs2) & (|rs2) ? mem1_rf_wdata
                : mem2_rf_we & (mem2_rf_waddr == rs2) & (|rs2) ? mem2_rf_wdata
                : wb_rf_we & (wb_rf_waddr == rs2) & (|rs2) ? wb_rf_wdata
                : rdata2;

    assign csr_vec = {32'b0, csr_vec_l};
    assign id2ex_bus = {
        csr_vec,        //64
        csr_op,         //4
        csr_addr,       //12
        csr_wdata_sel,  //1
        sel_src1,       //2
        sel_src2,       //1
        src1,
        src2,
        imm,
        alu_op,
        bru_op,
        lsu_op,
        mul_op,
        div_op,
        sel_rf_res,
        rf_we,
        rf_waddr,
        pc,
        inst
    };
    
    
endmodule