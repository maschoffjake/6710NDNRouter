module (
    input clk,
    input rst,
    output reg divided_clk
);

// Amount of ticks
parameter maxCount = 300;
reg [9:0] count;

always@(posedge clk, rst) begin
    if (rst)
        divided_clk <= 0;
        count <= 0;
    else begin
        if (count == maxCount) begin
            divided_clk <= ~divided_clk;
            count <= 0;
        end 
        else begin
            count <= count + 1;
        end
    end
end

endmodule