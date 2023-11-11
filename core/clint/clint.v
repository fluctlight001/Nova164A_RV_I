//*************************************************************************
//   > File Name   : clint.v
//   > Description : Control module of timer.
//
//   > Author      : rt_Ni
//   > Date        : 2022-12-10
//*************************************************************************
`define RANDOM_SEED {7'b1010101,16'h01FF}

`define MTIME_ADDR     16'hbff8 // 32'h0200_bff8
`define MTIME_H_ADDR   16'hbffc // 32'h0200_bffc
`define MTIMECMP_ADDR  16'h4000 // 32'h0200_4000

`define TIMER_CYCLE    49

module clint(                     
    input             clk,          
    input             timer_clk,
    input             resetn,     
    output            timer_int,
    // read and write from cpu
	input             clint_en,      
	input      [7 :0] clint_we,      
	input      [63:0] clint_addr,    
	input      [63:0] clint_wdata,   
	output     [63:0] clint_rdata  
);
    reg [63:0] mtime;
    reg [63:0] mtimecmp;
                        
    // read data has one cycle delay
    reg [63:0] clint_rdata_reg;
    assign clint_rdata = clint_rdata_reg;
    always @(posedge clk)
    begin
        if(~resetn)
        begin
            clint_rdata_reg <= 32'd0;
        end
        else if (clint_en)
        begin
            case (clint_addr[15:0])
                `MTIME_ADDR    : clint_rdata_reg <= mtime        ;
                `MTIME_H_ADDR  : clint_rdata_reg <= mtime        ;
                `MTIMECMP_ADDR : clint_rdata_reg <= mtimecmp     ;
                default        : clint_rdata_reg <= 32'd0;
            endcase
        end
    end

    //clint write, only support a word write
    assign we = clint_en & (|clint_we);

//-------------------------------{mtime}begin----------------------------//
    reg [9:0] tick_tock;
    always @ (posedge clk) begin
        if (!resetn) begin
            tick_tock <= 0;
        end
        else if (tick_tock == `TIMER_CYCLE) begin
            tick_tock <= 0;
        end
        else begin
            tick_tock <= tick_tock + 1;
        end
    end
    wire write_mtime = we & (clint_addr[15:0]==`MTIME_ADDR);
    always @ (posedge clk) begin
        if (!resetn) begin
            mtime <= 0;
        end
        else if (write_mtime) begin
            mtime <= clint_wdata;
        end
        else if (tick_tock == `TIMER_CYCLE) begin
            mtime <= mtime + 1;
        end
    end

    wire write_mtimecmp = we & (clint_addr[15:0]==`MTIMECMP_ADDR);
    always @ (posedge clk) begin
        if (!resetn) begin
            mtimecmp <= 0;// 64'hffff_ffff_ffff_ffff;
        end
        else if (write_mtimecmp) begin
            mtimecmp <= clint_wdata;
        end
    end
    assign timer_int = mtime >= mtimecmp ? 1'b1 : 1'b0;
//-------------------------------{mtime}end------------------------------//

endmodule
