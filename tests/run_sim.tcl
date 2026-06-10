open_project C:/Users/willi/OneDrive/Desktop/stroud/digital_logic/vivado_stuff/RISCV_CPU/RISCV_CPU.xpr
set_property top cpu_top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property generic {MEM_FILE=add.mem} [get_filesets sim_1]
launch_simulation
run all
close_sim
exit
