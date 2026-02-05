class cordic_ip_monitor extends uvm_monitor;

	`uvm_component_utils(cordic_ip_monitor)
	
	cordic_ip_agent_config iagt_cfg;
	virtual cordic_if.MON vif;
	uvm_analysis_port #(cordic_sequence_item) mon_ap;
	
	extern function new(string name = "cordic_ip_monitor",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	

endclass : cordic_ip_monitor

function cordic_ip_monitor::new(string name = "cordic_ip_monitor",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_ip_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(cordic_ip_agent_config)::get(this,"","iagt_cfg",iagt_cfg)) begin
		`uvm_fatal(get_type_name(),"Unable to get cordic_ip_agent_config");
	end
	mon_ap = new("mon_ap", this);
endfunction

function void cordic_ip_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = iagt_cfg.vif;
endfunction


task cordic_ip_monitor::run_phase(uvm_phase phase);
    cordic_sequence_item ip_seq;

	`uvm_info(get_type_name(), "IP Monitor: Waiting for reset...", UVM_LOW)
    wait(vif.Reset == 0);
    `uvm_info(get_type_name(), "IP Monitor: Reset complete, starting monitoring", UVM_LOW)

    forever begin
		@(vif.mon_cb);
		ip_seq = cordic_sequence_item::type_id::create("ip_seq");
		ip_seq.Input_angle = vif.mon_cb.Input_angle;
		ip_seq.Cos_out     = vif.mon_cb.Cos_out;  
		ip_seq.Sin_out     = vif.mon_cb.Sin_out;
		mon_ap.write(ip_seq);
    end
endtask

