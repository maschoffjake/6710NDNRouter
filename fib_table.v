/*
    This module is used for creating the FIB table of the NDN router
    
*/

module (

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [4:0] pit_in_len,
    input fib_out_bit,
    input start_send_to_pit,

    // DATA INPUTS
    input [4:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,

    // OVERALL INPUTS 
    input clk

);

endmodule // 