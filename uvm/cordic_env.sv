class cordic_env extends uvm_env;

	`uvm_component_utils(cordic_env)
	
	cordic_ip_agent iagt;
	cordic_op_agent oagt;
	cordic_env_config env_cfg;
	cordic_virtual_sequencer vseqr;
	cordic_scoreboard sb;
	
	extern function new(string name = "cordic_env", uvm_component parent); //null ?
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass : cordic_env

function cordic_env::new(string name = "cordic_env", uvm_component parent);
	super.new(name,parent);
endfunction

function void cordic_env:: build_phase(uvm_phase phase);
	super.build_phase(phase);
	vseqr = cordic_virtual_sequencer::type_id::create("vseqr", this);
	iagt = cordic_ip_agent::type_id::create("iagt",this);
	oagt = cordic_op_agent::type_id::create("oagt",this);
	env_cfg = cordic_env_config::type_id::create("env_cfg",this);
	sb = cordic_scoreboard::type_id::create("sb", this);
endfunction

function void cordic_env:: connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vseqr.ip_seqr = iagt.ip_seqr;
	iagt.analysis_export.connect(sb.ip2sb);
	oagt.analysis_export.connect(sb.op2sb); 
endfunction