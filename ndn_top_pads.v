`include "/research/ece/lnis-teaching/5710_6710/Lab_files/HDL/padlib_tsmc180_innovus.v"

`include "/home/kenta/digital_vlsi/synopsys_dc/HDL/GATE/ndn_mapped.v"

module ndn_top_pads(clk, rst, mosi_from_mcu, miso_to_mcu, miso_from_interface, mosi_to_interface, out_data, address, current_byte, write_enable, read_data);
input clk;
input rst;

input mosi_from_mcu;
output miso_to_mcu;
    
input miso_from_interface;
output mosi_to_interface;
output [7:0] out_data;     // input [7:0] 
output [9:0] address;      // input [9:0] 
output [9:0] current_byte; // input [9:0]
output write_enable; // input 
input [7:0] read_data;     // output [7:0]

wire [7:0] read_data_pad;
wire [7:0] out_data_pad;
wire [9:0] address_pad;
wire [9:0] current_byte_pad;

pad_in pad_in0 (.pad(clk), .DataIn(clk_pad));
pad_in pad_in1 (.pad(rst), .DataIn(rst_pad));
pad_in pad_in2 (.pad(mosi_from_mcu), .DataIn(mosi_from_mcu_pad));
pad_in pad_in3 (.pad(miso_from_interface), .DataIn(miso_from_interface_pad));
pad_in pad_in4 (.pad(read_data[0]), .DataIn(read_data_pad[0]));
pad_in pad_in5 (.pad(read_data[1]), .DataIn(read_data_pad[1]));
pad_in pad_in6 (.pad(read_data[2]), .DataIn(read_data_pad[2]));
pad_in pad_in7 (.pad(read_data[3]), .DataIn(read_data_pad[3]));
pad_in pad_in8 (.pad(read_data[4]), .DataIn(read_data_pad[4]));
pad_in pad_in9 (.pad(read_data[5]), .DataIn(read_data_pad[5]));
pad_in pad_in10 (.pad(read_data[6]), .DataIn(read_data_pad[6]));
pad_in pad_in11 (.pad(read_data[7]), .DataIn(read_data_pad[7]));

pad_out_buffered pad_out0 (.pad(miso_to_mcu), .out(miso_to_mcu_pad));
pad_out_buffered pad_out1 (.pad(mosi_to_interface), .out(mosi_to_interface_pad));
pad_out_buffered pad_out2 (.pad(out_data[0]), .out(out_data_pad[0]));
pad_out_buffered pad_out3 (.pad(out_data[1]), .out(out_data_pad[1]));
pad_out_buffered pad_out4 (.pad(out_data[2]), .out(out_data_pad[2]));
pad_out_buffered pad_out5 (.pad(out_data[3]), .out(out_data_pad[3]));
pad_out_buffered pad_out6 (.pad(out_data[4]), .out(out_data_pad[4]));
pad_out_buffered pad_out7 (.pad(out_data[5]), .out(out_data_pad[5]));
pad_out_buffered pad_out8 (.pad(out_data[6]), .out(out_data_pad[6]));
pad_out_buffered pad_out9 (.pad(out_data[7]), .out(out_data_pad[7]));
pad_out_buffered pad_out10 (.pad(address[0]), .out(address_pad[0]));
pad_out_buffered pad_out11 (.pad(address[1]), .out(address_pad[1]));
pad_out_buffered pad_out12 (.pad(address[2]), .out(address_pad[2]));
pad_out_buffered pad_out13 (.pad(address[3]), .out(address_pad[3]));
pad_out_buffered pad_out14 (.pad(address[4]), .out(address_pad[4]));
pad_out_buffered pad_out15 (.pad(address[5]), .out(address_pad[5]));
pad_out_buffered pad_out16 (.pad(address[6]), .out(address_pad[6]));
pad_out_buffered pad_out17 (.pad(address[7]), .out(address_pad[7]));
pad_out_buffered pad_out18 (.pad(address[8]), .out(address_pad[8]));
pad_out_buffered pad_out19 (.pad(address[9]), .out(address_pad[9]));
pad_out_buffered pad_out20 (.pad(current_byte[0]), .out(current_byte_pad[0]));
pad_out_buffered pad_out21 (.pad(current_byte[1]), .out(current_byte_pad[1]));
pad_out_buffered pad_out22 (.pad(current_byte[2]), .out(current_byte_pad[2]));
pad_out_buffered pad_out23 (.pad(current_byte[3]), .out(current_byte_pad[3]));
pad_out_buffered pad_out24 (.pad(current_byte[4]), .out(current_byte_pad[4]));
pad_out_buffered pad_out25 (.pad(current_byte[5]), .out(current_byte_pad[5]));
pad_out_buffered pad_out26 (.pad(current_byte[6]), .out(current_byte_pad[6]));
pad_out_buffered pad_out27 (.pad(current_byte[7]), .out(current_byte_pad[7]));
pad_out_buffered pad_out28 (.pad(current_byte[8]), .out(current_byte_pad[8]));
pad_out_buffered pad_out29 (.pad(current_byte[9]), .out(current_byte_pad[9]));
pad_out_buffered pad_out30 (.pad(write_enable), .out(write_enable_pad));

pad_vdd pad_vdd0 ();
pad_gnd pad_gnd0 ();

pad_corner pad_corner0 ();
pad_corner pad_corner1 ();
pad_corner pad_corner2 ();
pad_corner pad_corner3 ();

ndn NDN_Instance(
	.clk(clk_pad),
	.rst(rst_pad),

	.mosi_from_mcu(mosi_from_mcu_pad),
	.miso_to_mcu(miso_to_mcu_pad),
    
	.miso_from_interface(miso_from_interface_pad),
	.mosi_to_interface(mosi_to_interface_pad),
	.out_data(out_data_pad),
	.address(address_pad),
	.current_byte(current_byte_pad),
	.write_enable(write_enable_pad),
	.read_data(read_data_pad)
);
endmodule
