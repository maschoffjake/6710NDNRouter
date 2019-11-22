module ndn(

    // Overall inputs
    input clk,
    input rst,

    // Incoming inputs
    input [63:0] prefix,
    input [5:0] len,

    // Outgoing inputs
    input [5:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,
    input [7:0] in_data,

    // Incoming outputs
    output [7:0] out_data,

    // Outgoing outputs
    output clk,
    output [63:0] longest_matching_prefix,
    output [5:0] longest_matching_prefix_len,
    output ready,
    output [63:0] total_content,
    output [5:0] total_content_len
);

pit_hash_table pit_hash_table_module (
    .prefix         (), // input [63:0]
    .len            (), // input [5:0]
    .prefix_ready   (), // input
    .out_bit        (), // input
    .clk            (), // input
    .rst            (), // input
    .table_entry    (), // input [63:0]
    .pit_in_bit     (), // input
    .rejected       ()  // input
);

PIT pit_module (
    .table_entry    (), // input [63:0]
    .address        (), // output [61:0]
    .in_data        (), // input [7:0]
    .read_data      (), // input [7:0]
    .out_data       (), // output [7:0]
    .write_enable   (), // output
    .in_bit         (), // input
    .out_bit        (), // input
    .start_bit      (), // output
    .fib_out        (), // output
    .clk            (), // input
    .reset          ()  // input
);

fib fib_module (
    .pit_in_prefix                  (), // input [63:0] 
    .pit_in_len                     (), // input [5:0] 
    .fib_out_bit                    (), // input 
    .start_send_to_pit              (), // input 
    .rejected                       (), // input 
    .data_in_len                    (), // input [5:0] 
    .data_in_prefix                 (), // input [63:0] 
    .data_ready                     (), // input 
    .data_in                        (), // input [7:0] 
    .clk                            (), // input 
    .rst                            (), // input 
    .pit_out_len                    (), // output [5:0]
    .pit_out_prefix                 (), // output [63:0] 
    .prefix_ready                   (), // output 
    .out_data                       (), // output [7:0] 
    .longest_matching_prefix        (), // output [63:0] 
    .longest_matching_prefix_len    (), // output [5:0] 
    .ready_for_data                 (), // output 
    .clk_out                        ()  // output 
);

endmodule