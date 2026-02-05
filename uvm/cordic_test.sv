class cordic_base_test extends uvm_test;

	`uvm_component_utils(cordic_base_test)
	
	cordic_env env;
	cordic_env_config env_cfg;
	cordic_ip_agent_config iagt_cfg;
	cordic_op_agent_config oagt_cfg;
	//virtual cordic_if vif;

	extern function new(string name = "cordic_base_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern virtual function void end_of_elaboration_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : cordic_base_test

function cordic_base_test::new(string name = "cordic_base_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void cordic_base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	env_cfg = cordic_env_config::type_id::create("env_cfg");
	iagt_cfg = cordic_ip_agent_config::type_id::create("iagt_cfg");
	oagt_cfg = cordic_op_agent_config::type_id::create("oagt_cfg");

	// if(!uvm_config_db#(virtual cordic_if)::get(this, "", "cordic_if", vif)) begin
		// `uvm_fatal("VIF CONFIG", "Cannot get interface vif from config_db!")
	// end

	// iagt_cfg.vif = vif;
	// oagt_cfg.vif = vif;

	if(!(uvm_config_db#(virtual cordic_if)::get(this,"","cordic_if",iagt_cfg.vif))) begin
		`uvm_fatal("VIF CONFIG","Can not get interface vif from Config_db!!!");
	end
	
	iagt_cfg.is_active = UVM_ACTIVE;
	
	if(!(uvm_config_db#(virtual cordic_if)::get(this,"","cordic_if",oagt_cfg.vif))) begin
		`uvm_fatal("VIF CONFIG","Can not get interface vif from Config_db!!!");
	end
	oagt_cfg.is_active = UVM_PASSIVE;
	
	env_cfg.iagt_cfg = iagt_cfg;
	env_cfg.oagt_cfg = oagt_cfg;
	
	uvm_config_db#(cordic_env_config)::set(this,"*","env_cfg",env_cfg); //checkl this block 
	uvm_config_db#(cordic_ip_agent_config)::set(this, "env.iagt*", "iagt_cfg", iagt_cfg);
	uvm_config_db#(cordic_op_agent_config)::set(this, "env.oagt*", "oagt_cfg", oagt_cfg);
	env = cordic_env::type_id::create("env",this);
endfunction

function void cordic_base_test::end_of_elaboration_phase(uvm_phase phase);
	uvm_top.print_topology();
endfunction

task cordic_base_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	#20ns;
	phase.drop_objection(this);
endtask
//zero_ip_test
class zero_ip_test extends cordic_base_test;
	
	`uvm_component_utils(zero_ip_test)	

	zero_ip_seq zip_h;
	
	extern function new(string name = "zero_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : zero_ip_test

function zero_ip_test::new(string name = "zero_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void zero_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	zip_h = zero_ip_seq::type_id::create("zip_h");
endfunction

task zero_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	zip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask

//small_ip_test
class small_ip_test extends cordic_base_test;
	
	`uvm_component_utils(small_ip_test)	

	small_ip_seq s_ip_h;
	
	extern function new(string name = "small_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : small_ip_test

function small_ip_test::new(string name = "small_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void small_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	s_ip_h = small_ip_seq::type_id::create("s_ip_h");
endfunction

task small_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	s_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask

//first_quad_ip_test
class first_quad_ip_test extends cordic_base_test;
	
	`uvm_component_utils(first_quad_ip_test)	

	first_quad_ip_seq f_ip_h;
	
	extern function new(string name = "first_quad_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : first_quad_ip_test

function first_quad_ip_test::new(string name = "first_quad_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void first_quad_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	f_ip_h = first_quad_ip_seq::type_id::create("f_ip_h");
endfunction

task first_quad_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	f_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask

//second_quad_ip_seq
class second_quad_ip_test extends cordic_base_test;
	
	`uvm_component_utils(second_quad_ip_test)	

	second_quad_ip_seq sq_ip_h;
	
	extern function new(string name = "second_quad_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : second_quad_ip_test

function second_quad_ip_test::new(string name = "second_quad_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void second_quad_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	sq_ip_h = second_quad_ip_seq::type_id::create("sq_ip_h");
endfunction

task second_quad_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	sq_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask

//third_quad_ip_seq
class third_quad_ip_test extends cordic_base_test;
	
	`uvm_component_utils(third_quad_ip_test)	

	third_quad_ip_seq tq_ip_h;
	
	extern function new(string name = "third_quad_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : third_quad_ip_test

function third_quad_ip_test::new(string name = "third_quad_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void third_quad_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	tq_ip_h = third_quad_ip_seq::type_id::create("tq_ip_h");
endfunction

task third_quad_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	tq_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask


//fourth_quad_ip_seq
class fourth_quad_ip_test extends cordic_base_test;
	
	`uvm_component_utils(fourth_quad_ip_test)	

	fourth_quad_ip_seq fq_ip_h;
	
	extern function new(string name = "fourth_quad_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : fourth_quad_ip_test

function fourth_quad_ip_test::new(string name = "fourth_quad_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void fourth_quad_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	fq_ip_h = fourth_quad_ip_seq::type_id::create("fq_ip_h");
endfunction

task fourth_quad_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	fq_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask

//std_ip_test
class std_ip_test extends cordic_base_test;
	
	`uvm_component_utils(std_ip_test)	

	std_ip_seq std_ip_h;
	
	extern function new(string name = "std_ip_test",uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass : std_ip_test

function std_ip_test::new(string name = "std_ip_test", uvm_component parent = null);
	super.new(name,parent);
endfunction

function void std_ip_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	std_ip_h = std_ip_seq::type_id::create("std_ip_h");
endfunction

task std_ip_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
	std_ip_h.start(env.vseqr.ip_seqr);
	phase.drop_objection(this);
endtask