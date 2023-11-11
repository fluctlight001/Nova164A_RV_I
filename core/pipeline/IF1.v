`include "../define.v"
module IF1
#(
    parameter IF12IF2_WD = 50
)(
    input wire clk,
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [31:0] new_pc,
    input wire [32:0] br_bus,

    output wire [IF12IF2_WD-1:0] if12if2_bus,
    output wire inst_sram_en,
    output wire [7:0] inst_sram_we,
    output wire [63:0] inst_sram_addr,
    output wire [63:0] inst_sram_wdata
);
    reg pc_valid;
    reg [31:0] pc;
    wire [31:0] pc_next;

    wire br_e;
    wire [31:0] br_addr;

    assign {br_e, br_addr} = br_bus;

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_valid <= 0;
            pc <= 32'h7fff_fffc;
        end
        else if (flush) begin
            pc_valid <= 1;
            pc <= new_pc;
        end
        else if (!stall[0] & br_e) begin
            pc_valid <= 1;
            pc <= br_addr;
        end
        else if (!stall[0]) begin
            pc_valid <= 1;
            pc <= pc_next;
        end
    end

    assign pc_next = pc + 4;

    assign if12if2_bus = {pc_valid, pc};

    assign inst_sram_en     = flush | br_e ? 1'b0 : pc_valid;
    assign inst_sram_we     = 8'b0;
    assign inst_sram_addr   = pc;
    assign inst_sram_wdata  = 0;
endmodule