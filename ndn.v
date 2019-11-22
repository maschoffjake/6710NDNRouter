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

pit_hash_table pit_hash_table_val (
    .prefix         (), // input [63:0]
    .len            (), // input
    .prefix_ready   (), // input
    .out_bit        (), // input
    .clk            (), // input
    .rst            (), // input
    .table_entry    (), // input [63:0]
    .pit_in_bit     (), // input
    .rejected       ()  // input
);

endmodule