class cordic_op_agent_config extends uvm_object;
	`uvm_object_utils(cordic_op_agent_config)
	
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	virtual cordic_if vif;
	
endclass : cordic_op_agent_config