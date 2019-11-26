module spi_mcu_module();

wire miso, RX_valid, SPI_to_PIT_length;
wire [7:0] output_shift_register, SPI_to_PIT_length;
wire [63:0] SPI_to_PIT_prefix;

reg sclk, mosi, cs, clk, rst, PIT_to_SPI_bit;
reg [7:0] input_shift_register, PIT_to_SPI_prefix;
reg [63:0] PIT_to_SPI_prefix;


S0 SPI_MCU_testbench(
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