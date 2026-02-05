class cordic_ip_agent extends uvm_agent;

	`uvm_component_utils(cordic_ip_agent);
	
	cordic_ip_driver ip_drv;
	cordic_ip_monitor ip_mon;
	cordic_ip_sequencer ip_seqr;
	cordic_ip_agent_config iagt_cfg;
	uvm_analysis_port #(cordic_sequence_item) analysis_export;
	
	extern function new(string name = "cordic_ip_agent", uvm_component  parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	
endclass : cordic_ip_agent

function cordic_ip_agent::new(string name = "cordic_ip_agent",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_ip_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	iagt_cfg = cordic_ip_agent_config::type_id::create("iagt_cfg");
	
	if(!uvm_config_db#(cordic_ip_agent_config)::get(this,"","iagt_cfg",iagt_cfg)) begin
		`uvm_fatal(get_type_name(),"Unable to get cordic_ip_agent_config");
	end
	
	ip_mon = cordic_ip_monitor::type_id::create("ip_mon",this);
	uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active);
	if(iagt_cfg.is_active == UVM_ACTIVE) begin
		ip_drv = cordic_ip_driver::type_id::create("ip_drv",this);
		ip_seqr = cordic_ip_sequencer::type_id::create("ip_seqr",this);
	end
    analysis_export = new("analysis_export", this);
endfunction	

function void cordic_ip_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(iagt_cfg.is_active == UVM_ACTIVE) begin
		ip_drv.seq_item_port.connect(ip_seqr.seq_item_export);
	end
	ip_mon.mon_ap.connect(analysis_export); 
endfunction