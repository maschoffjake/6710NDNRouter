module ndn(

    // Overall inputs
    input clk,
    input rst,

    // Incoming inputs
    input [63:0] prefix,
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
    output clk_out,
    output [63:0] longest_matching_prefix,
    output [5:0] longest_matching_prefix_len,
    output ready_for_data,
    output [63:0] total_content,
    output [5:0] total_content_len
);

wire pit_in_bit;            // PITHASH --> PIT
wire prefix_ready;          // FIB --> PIT
wire [11:0] table_entry;    // PITHASH --> PIT
wire rejected;              // PITHASH --> FIB
wire [9:0] address;         // PIT --> RAM
wire [9:0] current_byte;    // PIT --> RAM
wire [7:0] read_data;       // RAM --> PIT
wire [7:0] out_data;        // PIT --> RAM/USER
wire write_enable;          // PIT --> RAM
wire start_send_to_pit;     // PIT --> FIB
wire fib_out_bit;           // PIT --> FIB
wire [63:0] pit_out_prefix; // FIB --> PIT
wire [5:0] pit_out_len;     // FIB --> PIT

assign user_data = out_data;

pit_hash_table pit_hash_table_module (
    .prefix         (prefix),         // input [63:0]
    .len            (len),            // input [5:0]
    .prefix_ready   (prefix_ready),   // input
    .pit_out_prefix (pit_out_prefix), // input [63:0]
    .pit_out_len    (pit_out_len),    // input [5:0]
    .out_bit        (out_bit),        // input
    .clk            (clk),            // input
    .rst            (rst),            // input
    .table_entry    (table_entry),    // output [11:0]
    .pit_in_bit     (pit_in_bit),     // output
    .rejected       (rejected)        // output
);

PIT pit_module (
    .table_entry    (table_entry),       // input [11:0]
    .in_data        (in_data),           // input [7:0]
    .read_data      (read_data),         // input [7:0]
    .in_bit         (pit_in_bit),        // input
    .out_bit        (out_bit),           // input
    .clk            (clk),               // input
    .reset          (rst),               // input
    .address        (address),           // output [9:0]
    .current_byte   (current_byte),      // output [9:0]
    .out_data       (out_data),          // output [7:0]
    .write_enable   (write_enable),      // output
    .start_bit      (start_send_to_pit), // output
    .fib_out        (fib_out_bit)        // output
);

fib_table fib_module (
    .pit_in_prefix                  (prefix), 			   // input [63:0] 
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
    .pit_out_len                    (pit_out_len), 		   // output [5:0]
    .pit_out_prefix                 (pit_out_prefix), 		   // output [63:0] 
    .prefix_ready                   (prefix_ready), 		   // output 
    .out_data                       (in_data), 			   // output [7:0] 
    .longest_matching_prefix        (longest_matching_prefix),     // output [63:0] 
    .longest_matching_prefix_len    (longest_matching_prefix_len), // output [5:0] 
    .ready_for_data                 (ready_for_data), 		   // output 
    .clk_out                        (clk_out)  			   // output 
);

single_port_ram ram(
	.data   (out_data),     // input [7:0] 
	.addr   (address),      // input [9:0] 
	.byte   (current_byte), // input [9:0]
	.we     (write_enable), // input 
    	.clk    (clk),          // input 
	.rst    (rst),		// input
	.q      (read_data)     // output [7:0] 
);

endmodule