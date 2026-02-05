class cordic_op_agent extends uvm_agent;

	`uvm_component_utils(cordic_op_agent)
    cordic_op_monitor op_mon;
	cordic_op_agent_config oagt_cfg;
	uvm_analysis_port #(cordic_sequence_item) analysis_export;

	extern function new(string name = "cordic_op_agent", uvm_component  parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);	
endclass : cordic_op_agent

function cordic_op_agent::new(string name = "cordic_op_agent",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_op_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	oagt_cfg = cordic_op_agent_config::type_id::create("oagt_cfg");
	
	if(!uvm_config_db#(cordic_op_agent_config)::get(this,"","oagt_cfg",oagt_cfg)) begin
		`uvm_fatal(get_type_name(),"Unable to get cordic_op_agent_config");
	end
	 if(oagt_cfg.is_active == UVM_PASSIVE)	begin
            op_mon = cordic_op_monitor::type_id::create("op_mon", this);
	end
    analysis_export = new("analysis_export", this);
endfunction	

function void cordic_op_agent::connect_phase(uvm_phase phase);
	 op_mon.mon_ap.connect(analysis_export); 
endfunction