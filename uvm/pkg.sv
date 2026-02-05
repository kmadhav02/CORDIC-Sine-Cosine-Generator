package pkg;

	`include "uvm_macros.svh"
	import uvm_pkg::*;
	

	`include "cordic_ip_agent_config.sv"
	`include "cordic_op_agent_config.sv"
	`include "cordic_env_config.sv"
	
	
	`include "cordic_sequence_item.sv"
	`include "cordic_ip_driver.sv"
	`include "cordic_ip_monitor.sv"
	`include "cordic_ip_sequencer.sv"

	

	`include "cordic_op_monitor.sv"

	`include "cordic_virtual_sequencer.sv"
	`include "cordic_base_sequence.sv"
	`include "cordic_ip_agent.sv"
	`include "cordic_op_agent.sv"
	`include "cordic_scoreboard.sv"
	`include "cordic_env.sv"

	`include "cordic_test.sv"
endpackage