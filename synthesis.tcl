# Optimization settings
# The period has to be changed to see if the design can meet the timing constraint
set period 30

#  Define the names to be used by the script
set design mips

# Define the directory paths
set BASE_DIR	 [pwd]
set RPT_DIR      "${BASE_DIR}/RPT"
set RTL_DIR 	 "${BASE_DIR}/HDL/RTL"
set GATE_DIR 	 "${BASE_DIR}/HDL/GATE"
set SDF_DIR 	 "${BASE_DIR}/SDF"
set SDC_DIR 	 "${BASE_DIR}/SDC"
set DDC_DIR 	 "${BASE_DIR}/DDC"
set DESIGN_LIB	 "${BASE_DIR}/DESIGN_LIBS/$design"


analyze -library WORK -format verilog {
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/single_port_ram.v 
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/pit_hash_table.v 
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/pit.v 
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/ndn.v 
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/hash.v 
/home/kenta/digital_vlsi/modelsim/PROJECTS/6710NDNRouter/fib_table.v}

elaborate ndn -architecture verilog -library WORK

write -hierarchy -format ddc -output /home/kenta/digital_vlsi/synopsys_dc/DDC/ndn_elab.ddc

create_clock -name "clk" -period 30 -waveform { 0 15  }  { clk  }

set_max_area 0

compile -exact_map

# Information
# Information: There are 126 potential problems in your design. Please run 'check_design' for more information. (LINT-99)
