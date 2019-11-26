module ndn(

    // Overall inputs
    input clk,
    input rst,

    input mosi_from_mcu;
    output miso_to_mcu;
    input cs_from_mcu;
    
    input miso_from_interface;
    output mosi_to_interface;
    input cs_to_interface;

    /*// Incoming inputs
    input [63:0] SPI_to_PIT_prefix,
    input [5:0] len,
    input out_bit,

    // Incoming outputs
    output [7:0] user_data,

    // Outgoing inputs
    input [5:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,
    input [7:0] in_data,

    // Outgoing outputs
    output [63:0] longest_matching_prefix,
    output [5:0] longest_matching_prefix_len,
    output ready_for_data,
    output [63:0] total_content,
    output [5:0] total_content_len*/
);

wire pit_in_bit;            // PITHASH --> PIT
wire prefix_ready;          // FIB --> PIT
wire [10:0] table_entry;    // PITHASH --> PIT
wire rejected;              // PITHASH --> FIB
wire [9:0] address;         // PIT --> RAM
wire [9:0] current_byte;    // PIT --> RAM
wire [7:0] read_data;       // RAM --> PIT
wire [7:0] out_data;        // PIT --> RAM/USER
wire [7:0] data_fib_to_pit;
wire [7:0] FIB_to_PIT_metadata;// FIB --> PITHASH
wire [7:0] metadata;		// PITHASH --> FIB
wire write_enable;          // PIT --> RAM
wire start_send_to_pit;     // PIT --> FIB
wire fib_out_bit;           // PIT --> FIB
wire [63:0] FIB_to_PIT_prefix; // FIB --> PIT
wire interest_packet;        // PITHASH --> PIT
//wire [5:0] pit_out_len;     // FIB --> PIT

assign user_data = out_data;

pit_hash_table pit_hash_table_module (
    .SPI_to_PIT_prefix         	(SPI_to_PIT_prefix),         // input [63:0]
    .prefix_ready   			(prefix_ready),   // input
    .FIB_to_PIT_prefix 			(FIB_to_PIT_prefix), // input [63:0]
    .length    					(len),    		  // input [5:0]
	.FIB_to_PIT_metadata		(FIB_to_PIT_metadata),// input [7:0]
    .out_bit        			(out_bit),        // input
    .clk           			 	(clk),            // input
    .rst            			(rst),            // input
    .table_entry    			(table_entry),    // output [11:0]
	.metadata       			(metadata),        // output [7:0]
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
    .fib_out        (fib_out_bit)        // output
);

fib_table fib_module (
    .pit_in_prefix                  (SPI_to_PIT_prefix), 			   // input [63:0] 
    .pit_in_len                     (len), 			   // input [5:0] 
    .fib_out_bit                    (fib_out_bit), 		   // input 
    .start_send_to_pit              (start_send_to_pit), 	   // input 
    .rejected                       (rejected), 		   // input 
    .data_in_len                    (data_in_len), 		   // input [5:0] 
    .data_in_prefix                 (data_in_prefix), 		   // input [63:0] 
    .data_ready                     (data_ready), 		   // input 
    .data_in                        (in_data), 			   // input [7:0] 
    .clk                            (clk), 			   // input 
    .rst                            (rst), 			   // input 
    //.pit_out_len                    (pit_out_len), 		   // output [5:0]
    .pit_out_prefix                 (FIB_to_PIT_prefix), 		   // output [63:0] 
    .prefix_ready                   (prefix_ready), 		   // output 
    .out_data                       (data_fib_to_pit), 		   // output [7:0] 
    .longest_matching_prefix        (longest_matching_prefix),     // output [63:0] 
    .longest_matching_prefix_len    (longest_matching_prefix_len), // output [5:0] 
    .ready_for_data                 (ready_for_data) 		   // output
);

single_port_ram ram (
	.data   (out_data),     // input [7:0] 
	.addr   (address),      // input [9:0] 
	.byte   (current_byte), // input [9:0]
	.we     (write_enable), // input 
    .clk    (clk),          // input 
	.rst    (rst),		// input
	.q      (read_data)     // output [7:0] 
);

module spi_mcu(
    mosi, //Input
    miso, //Output
    cs, //Input
    // Overall input
    clk, //Input
    rst, //Input
    // Receiving output
    RX_valid, //Output              // Valid pulse for 1 cycle for RX byte to know data is ready
    output_shift_register, //Output[7:0]  // Used to send data to the FIB 
    // Transferring input
    TX_valid, //Input             // Valid pulse for 1 cycle for TX byte
    input_shift_register, //Input

	input reg 			PIT_to_SPI_bit, //Input
	input reg [7:0] 	PIT_to_SPI_data, //Input[7:0]
	input reg [63:0] 	PIT_to_SPI_prefix, //input[63:0]
	output reg 			SPI_to_PIT_bit, //Output
	output reg [7:0]    SPI_to_PIT_length, //Output
	output reg [63:0]   SPI_to_PIT_prefix //Output
);

spi_interface spi_module(
    // SPI interfaces
    mosi(mosi_to_interface), //Output
    miso(miso_from_interface), //Input
    cs(cs_to_interface), //Output
    // Overall inputs
    clk(clk), //Input
    rst(rst), //Input
    // Receiving output
    RX_valid(), //Output              // Valid pulse for 1 cycle for RX byte to know data is ready
    output_shift_register(), //Output[7:0] // Used to send data to the FIB 
    // Transferring input
    TX_valid(), //Input                  // Valid pulse for 1 cycle for TX byte
    input_shift_register() //Input
);

endmodule