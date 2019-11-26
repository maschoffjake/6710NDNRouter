module ndn(

    // Overall inputs
    input clk,
    input rst,

    input mosi_from_mcu,
    output miso_to_mcu,
    input cs_from_mcu,
    
    input miso_from_interface,
    output mosi_to_interface,
    output cs_to_interface,
    output [7:0] out_data,     // input [7:0] 
    output [9:0] address,      // input [9:0] 
    output [9:0] current_byte, // input [9:0]
    output write_enable, // input 
    input [7:0] read_data     // output [7:0] 
);

wire pit_in_bit;            // PITHASH --> PIT
wire prefix_ready;          // FIB --> PIT
wire [10:0] table_entry;    // PITHASH --> PIT
wire rejected;              // PITHASH --> FIB
//wire [9:0] address;         // PIT --> RAM
//wire [9:0] current_byte;    // PIT --> RAM
//wire [7:0] read_data;       // RAM --> PIT
//wire [7:0] out_data;        // PIT --> RAM/USER
wire [7:0] data_fib_to_pit;
wire [7:0] FIB_to_PIT_metadata;// FIB --> PITHASH
wire [7:0] metadata;		// PITHASH --> FIB
//wire write_enable;          // PIT --> RAM
wire start_send_to_pit;     // PIT --> FIB
wire fib_out_bit;           // PIT --> FIB
wire [63:0] FIB_to_PIT_prefix; // FIB --> PIT
wire interest_packet;        // PITHASH --> PIT
wire RX_valid;
wire TX_valid;
wire [7:0] data_fib_to_spi;
wire [7:0] data_spi_to_fib;
wire [63:0] SPI_to_PIT_prefix;
wire [5:0] len;
wire out_bit;
wire PIT_to_SPI_bit;
//wire [5:0] pit_out_len;     // FIB --> PIT



pit_hash_table pit_hash_table_module (
    .SPI_to_PIT_prefix         	(SPI_to_PIT_prefix),         // input [63:0]
    .prefix_ready   			(prefix_ready),   // input
    .FIB_to_PIT_prefix 			(FIB_to_PIT_prefix), // input [63:0]
    .length    				    (len),    		  // input [5:0]
    .FIB_to_PIT_metadata		(FIB_to_PIT_metadata),// input [7:0]
    .out_bit        			(out_bit),        // input
    .clk           			    (clk),            // input
    .rst            			(rst),            // input
    .table_entry    			(table_entry),    // output [11:0]
    .meta_data       			(metadata),        // output [7:0]
    .pit_in_bit     			(pit_in_bit),     // output
    .rejected       			(rejected),        // output
    .interest_packet			(interest_packet)
);

PIT pit_module (
    .table_entry    (table_entry[10:0]), // input [11:0]
    .in_data        (data_fib_to_pit),   // input [7:0]
    .read_data      (read_data),         // input [7:0]
    .in_bit         (pit_in_bit),        // input
    .out_bit        (out_bit),           // input
    .clk            (clk),               // input
    .reset          (rst),               // input
    .interest_packet(interest_packet),    // input
    .address        (address),           // output [9:0]
    .current_byte   (current_byte),      // output [9:0]
    .out_data       (out_data),          // output [7:0]
    .write_enable   (write_enable),      // output
    .start_bit      (start_send_to_pit), // output
    .PIT_to_SPI_bit (PIT_to_SPI_bit), 	 //output
    .fib_out        (fib_out_bit)        // output
);

fib_table fib_module (
    .pit_in_prefix                  (SPI_to_PIT_prefix), 			   // input [63:0] 
    .pit_in_metadata(metadata), //Input [7:0]
    .rejected                       (rejected), 		   // input
    .fib_out_bit                    (fib_out_bit), 		   // input  
    .start_send_to_pit              (start_send_to_pit), 	   // input
    .data_PIT_to_FIB(out_data), //Input [7:0] 
    .RX_valid(RX_valid), //Input     
    .data_SPI_to_FIB(data_spi_to_fib), //Input [7:0]
    .clk                            (clk), 			   // input 
    .rst                            (rst), 			   // input 
    .pit_out_prefix                 (FIB_to_PIT_prefix), 		   // output [63:0] 
    .prefix_ready                   (prefix_ready), 		   // output 
    .pit_out_metadata(FIB_to_PIT_metadata), //Output [7:0]
    .data_FIB_to_PIT(data_fib_to_pit), //Output [7:0]
    .FIB_to_SPI_data_flag(TX_valid), //Output  TX
    .data_FIB_to_SPI(data_fib_to_spi) //Output [7:0]
);

/*single_port_ram ram (
	.data   (out_data),     // input [7:0] 
	.addr   (address),      // input [9:0] 
	.byte   (current_byte), // input [9:0]
	.we     (write_enable), // input 
    .clk    (clk),          // input 
	.rst    (rst),		// input
	.q      (read_data)     // output [7:0] 
);*/

spi_mcu spi_mcu_module(
    .mosi(mosi_from_mcu), //Input
    .miso(miso_to_mcu), //Output
    .clk(clk), //Input
    .rst(rst), //Input
	.cs(cs_from_mcu),
    .PIT_to_SPI_bit(PIT_to_SPI_bit), //Input
    .PIT_to_SPI_data(out_data), //Input[7:0]
    .PIT_to_SPI_prefix(FIB_to_PIT_prefix), //input[63:0]
    .SPI_to_PIT_bit(interest_packet), //Output
    .SPI_to_PIT_length(len), //Output[5:0]
    .SPI_to_PIT_prefix(SPI_to_PIT_prefix) //Output[63:0]
);

spi_interface spi_interface_module(
    .mosi(mosi_to_interface), //Output
    .miso(miso_from_interface), //Input
    .clk(clk), //Input
    .rst(rst), //Input
    .RX_valid(RX_valid), //Outputs
    .output_shift_register(data_spi_to_fib), //Output[7:0]
    .TX_valid(TX_valid), //Input
    .input_shift_register(data_fib_to_spi) //Input
);

endmodule