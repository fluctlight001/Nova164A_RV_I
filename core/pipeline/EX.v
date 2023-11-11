`include "../define.v"
module EX #(
    parameter ID2EX_WD = 50,
    parameter EX2MEM1_WD = 50,
    parameter EX2ID_WD = 50
) (
    input wire clk, 
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    output wire [32:0] br_bus,

    input wire [ID2EX_WD-1:0] id2ex_bus,
    output wire [EX2MEM1_WD-1:0] ex2mem1_bus,
    output wire [EX2ID_WD-1:0] ex2id_fwd,

    output wire data_sram_en,
    output wire [7:0] data_sram_we,
    output wire [63:0] data_sram_addr,
    output wire [63:0] data_sram_wdata
);
    reg [ID2EX_WD-1:0] id2ex_bus_r;
    always @(posedge clk) begin
        if (!rst_n) begin
            id2ex_bus_r <= 0;
        end
        else if (flush) begin
            id2ex_bus_r <= 0;
        end
        else if (stall[3]&(!stall[4])) begin
            id2ex_bus_r <= 0;
        end
        else if ((!stall[3]&br_bus[32])) begin
            id2ex_bus_r <= 0;
        end
        else if (!stall[3]) begin
            id2ex_bus_r <= id2ex_bus;
        end
    end

    wire [1:0] sel_src1;
    wire sel_src2;
    wire [4:0] rs1, rs2;
    wire [63:0] rdata1, rdata2;
    wire [63:0] imm;
    wire [14:0] alu_op;
    wire [7:0] bru_op;
    wire [6:0] lsu_op;
    wire [4:0] mul_op;
    wire [3:0] div_op;
    wire [3:0] sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [63:0] pc;
    wire [31:0] inst;
    wire [3:0] csr_op;
    wire [11:0] csr_addr;
    wire csr_wdata_sel;
    wire [63:0] csr_wdata;
    wire [79:0] csr_bus;
    wire [63:0] csr_vec;

    assign {
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
    } = id2ex_bus_r;
        
    wire [63:0] alu_src1, alu_src2;
    assign alu_src1 = sel_src1[0] ? pc
                    : sel_src1[1] ? 64'b0
                    : src1;
    assign alu_src2 = sel_src2 ? imm 
                    : src2;

    wire [63:0] alu_result;
    alu u_alu(
    	.alu_op     (alu_op     ),
        .alu_src1   (alu_src1   ),
        .alu_src2   (alu_src2   ),
        .alu_result (alu_result )
    );

    wire br_e;
    wire [63:0] br_addr;
    wire [63:0] br_result;
    bru u_bru(
    	.pc        (pc        ),
        .bru_op    (bru_op    ),
        .rdata1    (src1      ),
        .rdata2    (src2      ),
        .imm       (imm       ),
        .br_e      (br_e      ),
        .br_addr   (br_addr   ),
        .br_result (br_result )
    );
    assign br_bus = {br_e,br_addr};

    wire [7:0] data_ram_sel;
    lsu u_lsu(
    	.lsu_op          (lsu_op          ),
        .rdata1          (src1            ),
        .rdata2          (src2            ),
        .imm             (imm             ),
        .data_sram_en    (data_sram_en    ),
        .data_sram_we    (data_sram_we    ),
        .data_sram_addr  (data_sram_addr ),
        .data_sram_wdata (data_sram_wdata ),
        .data_ram_sel    (data_ram_sel    )
    );

    wire [63:0] ex_result;
    assign ex_result = sel_rf_res[0] ? br_result : alu_result;

    assign ex2mem1_bus = {
        lsu_op,
        data_ram_sel,
        sel_rf_res[1],
        rf_we,
        rf_waddr,
        ex_result,
        pc,
        inst
    };

    assign ex2id_fwd = {
        rf_we,
        rf_waddr,
        ex_result
    };
endmodule