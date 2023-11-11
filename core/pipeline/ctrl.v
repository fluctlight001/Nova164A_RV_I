`include "../define.v"
module  ctrl (
    input wire rst_n,
    input wire stallreq_id,
    output reg [`StallBus-1:0] stall
);
    always @(*) begin
        if (!rst_n) begin
            stall = `StallBus'b0;
        end
        else if (stallreq_id) begin
            //TODO
            stall = `StallBus'b00001111; 
        end
        else begin
            stall = `StallBus'b0;
        end
    end
    
endmodule