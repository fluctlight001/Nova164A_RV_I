`include "define.v"
module IF2 
#(
    parameter IF12IF2_WD = 50,
    parameter IF22ID_WD = 50
)
(
    input wire clk, 
    input wire rst_n,
    input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [32:0] br_bus,
    input wire [63:0] inst_sram_rdata,

    input wire [IF12IF2_WD-1:0] if12if2_bus,
    output wire [IF22ID_WD-1:0] if22id_bus
);
    reg [IF12IF2_WD-1:0] if12if2_bus_r;
    reg [31:0] inst_sram_rdata_r;
    wire br_e;
    wire [31:0] br_addr;
    assign {br_e, br_addr} = br_bus;
    wire pc_valid;
    wire [31:0] pc;
    assign {pc_valid, pc} = if12if2_bus;

    always @(posedge clk) begin
        if (!rst_n) begin
            if12if2_bus_r <= 0;
            inst_sram_rdata_r <= 0;
        end
        //冲刷流水线
        else if (flush) begin
            if12if2_bus_r <= 0;
            inst_sram_rdata_r <= 0;
        end
        //本段暂停，下一段不暂停
        else if (stall[1]&(!stall[2])) begin
            if12if2_bus_r <= 0;
            inst_sram_rdata_r <= 0;
        end
        //本段不暂停，但是有跳转
        else if ((!stall[1])&br_e) begin
            if12if2_bus_r <= 0;
            inst_sram_rdata_r <= 0;
        end
        //正常运行
        else if ((!stall[1])) begin
            if12if2_bus_r <= if12if2_bus;
            inst_sram_rdata_r <= pc[2] ? inst_sram_rdata[63:32] : inst_sram_rdata[31:0];
        end
    end

    assign if22id_bus = {inst_sram_rdata_r, if12if2_bus_r};
    
endmodule