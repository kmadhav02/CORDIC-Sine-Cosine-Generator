class cordic_virtual_sequencer extends uvm_sequencer#(cordic_sequence_item);

	`uvm_component_utils(cordic_virtual_sequencer)
	
	cordic_ip_sequencer ip_seqr;
	
	extern function new(string name = "cordic_virtual_sequencer", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	
endclass : cordic_virtual_sequencer

function cordic_virtual_sequencer::new(string name = "cordic_virtual_sequencer", uvm_component parent);
	super.new(name,parent);
endfunction

function void cordic_virtual_sequencer::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	ip_seqr = cordic_ip_sequencer::type_id::create("ip_seqr",this);
endfunction

