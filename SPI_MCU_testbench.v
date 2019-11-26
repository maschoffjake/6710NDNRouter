module spi_mcu_module();

wire miso, RX_valid, SPI_to_PIT_bit;
wire [7:0] output_shift_register, SPI_to_PIT_length;
wire [63:0] SPI_to_PIT_prefix;

reg sclk, mosi, cs, clk, rst, PIT_to_SPI_bit;
reg [7:0] input_shift_register;
reg [63:0] PIT_to_SPI_prefix;
reg [7:0] PIT_to_SPI_data;

parameter length_sz = 6, prefix_sz = 64, idle = 0, start = 1, rx = 2, next = 3, tx = 4, done = 5;

reg [2:0] state;
reg [8:0] rx_count;

spi_mcu SPI_MCU_testbench(
	.sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .cs(cs),

    // Overall inputs
    .clk(clk),
    .rst(rst),

    // Receiving output
    .RX_valid(RX_valid),               // Valid pulse for 1 cycle for RX byte to know data is ready
    .output_shift_register(output_shift_register),  // Used to send data to the FIB 

    // Transferring input
    .TX_valid(TX_valid),              // Valid pulse for 1 cycle for TX byte
    .input_shift_register(input_shift_register),

	.PIT_to_SPI_bit(PIT_to_SPI_bit),
	.PIT_to_SPI_data(PIT_to_SPI_data),
	.PIT_to_SPI_prefix(PIT_to_SPI_prefix),
	.SPI_to_PIT_bit(SPI_to_PIT_bit),
	.SPI_to_PIT_length(SPI_to_PIT_length),
	.SPI_to_PIT_prefix(SPI_to_PIT_prefix)
);

reg transmitting;
reg [5:0]  rx_meta_data_test;     
reg [63:0] rx_prefix_test;
reg [70:0] rx_data;
reg [63:0] pit_to_spi;
reg [255:0] pit_data;

initial begin

	rx_meta_data_test = 6'b101010;
	rx_prefix_test = 64'd129;
	PIT_to_SPI_prefix = 64'd129;
	pit_data = "here is data";
	state = idle;
	rx_data = {1'b0, rx_meta_data_test, rx_prefix_test};
	transmitting = 1;
	clk = 0;
	rst = 0;
	rx_count = 71;
	#2
	rst = 1;
	#2
	rst = 0;
end

always begin
		#10 clk <= ~clk;
		if(clk) begin
		if(transmitting) begin
		case(state)
			idle: begin
				PIT_to_SPI_bit = 1;
				state <= next;
			end
			next: begin
			PIT_to_SPI_bit = 0;
			PIT_to_SPI_data <= pit_data[255:248];
			pit_data = pit_data << 8;
			end
		endcase
		end
		else begin
		case(state)
			idle: begin
				state <= start;
			end
			start: begin
				if(rx_count > 0) begin
				mosi <= rx_data[70];
				rx_count <= rx_count - 1;
				rx_data <= rx_data << 1;
				end
				else begin
					state <= rx;
				end
			end
			rx: begin
			end
		endcase
		end
		end

end
endmodule