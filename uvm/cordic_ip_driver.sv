class cordic_ip_driver extends uvm_driver #(cordic_sequence_item);

	`uvm_component_utils(cordic_ip_driver)
	
	cordic_ip_agent_config iagt_cfg;
	virtual cordic_if.DRV vif;
	
	extern function new(string name = "cordic_ip_driver",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_item(cordic_sequence_item req);

endclass : cordic_ip_driver

function cordic_ip_driver::new(string name = "cordic_ip_driver",uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_ip_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(cordic_ip_agent_config)::get(this,"","iagt_cfg",iagt_cfg)) begin
		`uvm_fatal(get_type_name(),"Unable to get cordic_ip_agent_config");
	end
	vif = iagt_cfg.vif;
endfunction

task cordic_ip_driver::run_phase(uvm_phase phase);
	cordic_sequence_item req;
        forever begin
           seq_item_port.get_next_item(req);
		   req.print();
		   drive_item(req);
           seq_item_port.item_done();
		end
endtask

task cordic_ip_driver::drive_item(cordic_sequence_item req);
    @(vif.drv_cb);
    vif.drv_cb.Input_angle <= req.Input_angle;
    repeat(20) @(vif.drv_cb);
endtask