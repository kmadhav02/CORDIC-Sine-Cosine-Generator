class cordic_op_monitor extends uvm_monitor;

	`uvm_component_utils(cordic_op_monitor)
	
	cordic_op_agent_config oagt_cfg;

	virtual cordic_if.MON vif; 
 
	uvm_analysis_port #(cordic_sequence_item) mon_ap;
	
	extern function new(string name = "cordic_op_monitor",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : cordic_op_monitor

function cordic_op_monitor::new(string name = "cordic_op_monitor",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_op_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	mon_ap = new("mon_ap", this);
	if(!uvm_config_db#(cordic_op_agent_config)::get(this,"","oagt_cfg",oagt_cfg)) begin
		`uvm_fatal(get_type_name(),"Unable to get cordic_op_agent_config");
	end
endfunction

function void cordic_op_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = oagt_cfg.vif;
endfunction

task cordic_op_monitor::run_phase(uvm_phase phase);
    cordic_sequence_item op_seq;
	`uvm_info(get_type_name(), "OP Monitor: Waiting for reset...", UVM_LOW)
    wait(vif.Reset == 0);
    `uvm_info(get_type_name(), "OP Monitor: Reset complete, starting monitoring", UVM_LOW)	

	forever begin
		repeat(21) @(vif.mon_cb);
		op_seq = cordic_sequence_item::type_id::create("op_seq");
		op_seq.Input_angle = vif.mon_cb.Input_angle;
		op_seq.Cos_out = vif.mon_cb.Cos_out;
		op_seq.Sin_out = vif.mon_cb.Sin_out;
		mon_ap.write(op_seq);
		op_seq.print();
	end
endtask
