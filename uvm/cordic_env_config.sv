class cordic_env_config extends uvm_object;

	`uvm_object_utils(cordic_env_config)
	
	cordic_ip_agent_config iagt_cfg;
	cordic_op_agent_config oagt_cfg;


	extern function new(string name = "cordic_env_config");

endclass : cordic_env_config

function cordic_env_config::new(string name = "cordic_env_config");
	super.new(name);
endfunction