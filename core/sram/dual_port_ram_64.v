module dual_port_ram_64 (
input  wire         clka,
input  wire         ena,
input  wire [7:0]   wea,
input  wire [15:0]  addra,
input  wire [63:0]  dina,
output reg  [63:0]  douta,

input  wire         clkb,
input  wire         enb,
input  wire [7:0]   web,
input  wire [15:0]  addrb,
input  wire [63:0]  dinb,
output reg  [63:0]  doutb
);

parameter  MEMDEPTH = 2**(16);

reg [63:0] mem [(MEMDEPTH-1):0] /* synthesis syn_ramstyle = "no_rw_check" */;

wire[7:0] mema_0 = mem[addra][7:0];
wire[7:0] mema_1 = mem[addra][15:8];
wire[7:0] mema_2 = mem[addra][23:16];
wire[7:0] mema_3 = mem[addra][31:24];
wire[7:0] mema_4 = mem[addra][39:32];
wire[7:0] mema_5 = mem[addra][47:40];
wire[7:0] mema_6 = mem[addra][55:48];
wire[7:0] mema_7 = mem[addra][63:56];

wire[7:0] memwa_0 = wea[0] ? dina[7:0]    : mema_0;
wire[7:0] memwa_1 = wea[1] ? dina[15:8]   : mema_1;
wire[7:0] memwa_2 = wea[2] ? dina[23:16]  : mema_2;
wire[7:0] memwa_3 = wea[3] ? dina[31:24]  : mema_3;
wire[7:0] memwa_4 = wea[4] ? dina[39:32]  : mema_4;
wire[7:0] memwa_5 = wea[5] ? dina[47:40]  : mema_5;
wire[7:0] memwa_6 = wea[6] ? dina[55:48]  : mema_6;
wire[7:0] memwa_7 = wea[7] ? dina[63:56]  : mema_7;

wire [63:0] memwa_data = {memwa_7, memwa_6, memwa_5, memwa_4, memwa_3, memwa_2, memwa_1, memwa_0};

// wire TEST_JUDGE = mem[16'h008b] == 32'h0984_0913;

always @(posedge clka)
begin
  if(|wea)
  begin
    if(ena)begin
      mem[addra]     <= memwa_data;
    end
    douta            <= dina;
  end
  else
  begin
    douta            <= mem[addra];
  end
end

wire[7:0] memb_0 = mem[addrb][7:0];
wire[7:0] memb_1 = mem[addrb][15:8];
wire[7:0] memb_2 = mem[addrb][23:16];
wire[7:0] memb_3 = mem[addrb][31:24];
wire[7:0] memb_4 = mem[addrb][39:32];
wire[7:0] memb_5 = mem[addrb][47:40];
wire[7:0] memb_6 = mem[addrb][55:48];
wire[7:0] memb_7 = mem[addrb][63:56];

wire[7:0] memwb_0 = web[0] ? dinb[7:0]    : memb_0;
wire[7:0] memwb_1 = web[1] ? dinb[15:8]   : memb_1;
wire[7:0] memwb_2 = web[2] ? dinb[23:16]  : memb_2;
wire[7:0] memwb_3 = web[3] ? dinb[31:24]  : memb_3;
wire[7:0] memwb_4 = web[4] ? dinb[39:32]  : memb_4;
wire[7:0] memwb_5 = web[5] ? dinb[47:40]  : memb_5;
wire[7:0] memwb_6 = web[6] ? dinb[55:48]  : memb_6;
wire[7:0] memwb_7 = web[7] ? dinb[63:56]  : memb_7;

wire [63:0] memwb_data = {memwb_7, memwb_6, memwb_5, memwb_4, memwb_3, memwb_2, memwb_1, memwb_0};

always @(posedge clkb)
begin
  if(|web)
  begin
    if(enb)begin
      mem[addrb]     <= memwb_data;
    end
    doutb            <= dinb;
  end
  else
  begin
    doutb            <= mem[addrb];
  end
end

endmodule
