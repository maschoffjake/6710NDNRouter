module ndn_testbench();

reg clk_tb;
reg rst_tb;
reg [2:0] state;

// Incoming inputs
reg [63:0] prefix_tb;
reg [5:0] len_tb;
reg out_bit_tb;

// Outgoing inputs
reg [5:0] data_in_len_tb;
reg [63:0] data_in_prefix_tb;
reg data_ready_tb;
reg [7:0] in_data_tb;


wire clk_out_tb;
wire [63:0] longest_matching_prefix_tb;
wire [5:0] longest_matching_prefix_len_tb;
wire ready_for_data_tb;
wire [63:0] total_content_tb;
wire [5:0] total_content_len_tb;

parameter idle = 3'b000;
parameter sending = 3'b001;
parameter waiting = 3'b010;

ndn N0 (
.clk(clk_tb),
.rst(rst_tb),

 // Incoming inputs
.prefix(prefix_tbv),
.len(len_tb),
.out_bit(out_bit_tb),

    // Outgoing inputs
.data_in_len(data_in_len_tb),
.data_in_prefix(data_in_prefix_tb),
.data_ready(data_ready_tb),
.in_data(in_data_tb),

    // Incoming outputs
.user_data(user_data_tb),

    // Outgoing outputs
.clk_out(clk_out_tb),
.longest_matching_prefix(longest_matching_prefix_tb),
.longest_matching_prefix_len(longest_matching_prefix_len_tb),
.ready_for_data(ready_for_data_tb),
.total_content(total_content_tb),
.total_content_len(total_content_len_tb)
);


initial
begin
	prefix_tb = 64'd28;
	len_tb = 5'b00101;
	state = idle;
	clk_tb = 0;
	out_bit_tb = 0;
end

always
begin
	#10 clk_tb = ~clk_tb;
	if(clk_tb)
	begin
		case(state)
			idle:
			begin
			state <= sending;
			end
			sending:
			begin	
			out_bit_tb <= 1;
			state <= waiting;
			end
			waiting:
			begin
			out_bit_tb <= 0;
			end
		endcase
	end
end


endmodule