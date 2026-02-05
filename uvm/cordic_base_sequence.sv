class cordic_base_sequence extends uvm_sequence#(cordic_sequence_item);

	`uvm_object_utils(cordic_base_sequence)
	
	cordic_ip_sequencer ip_seqr;
	cordic_virtual_sequencer vseqr;
	cordic_env_config env_cfg;


	extern function new(string name = "cordic_base_Sequence");
	extern virtual task body();
	
endclass :cordic_base_sequence

function cordic_base_sequence::new(string name = "cordic_base_Sequence");
	super.new(name);
endfunction

task cordic_base_sequence::body();
    if(!uvm_config_db#(cordic_env_config)::get(null, get_full_name(), "env_cfg", env_cfg)) begin
        `uvm_fatal("CONFIG", "Cannot get() env_cfg from uvm_config_db. Have you set() it?")
    end
    
    if(!$cast(vseqr, m_sequencer)) begin
        `uvm_error("BODY", "Error in $cast of virtual_sequencer")
    end
    
    ip_seqr = vseqr.ip_seqr;
endtask


// zero_ip_seq   
class zero_ip_seq extends cordic_base_sequence;
    `uvm_object_utils(zero_ip_seq)
	
	extern function new(string name = "zero_ip_seq");
	extern task body();
endclass : zero_ip_seq
	
function zero_ip_seq::new(string name = "zero_ip_seq"); 
         super.new(name); 
endfunction

task zero_ip_seq::body();
	repeat (1) begin
		req= cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle == 17'd360; });
		finish_item(req);
	end
endtask 

// small_ip_seq
class small_ip_seq extends cordic_base_sequence;
  `uvm_object_utils(small_ip_seq)

	extern function new(string name = "small_ip_seq");
	extern task body();
endclass : small_ip_seq

function small_ip_seq::new(string name = "small_ip_seq");
	super.new(name);
endfunction

task small_ip_seq::body(); 
	repeat (20) begin
		req = cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle inside {[17'd1 : 17'd20]};});
		finish_item(req);
	end
endtask

//first_quad_ip_seq
class first_quad_ip_seq extends cordic_base_sequence;
    `uvm_object_utils(first_quad_ip_seq)
	
	extern function new(string name = "first_quad_ip_seq");
	extern task body();
endclass : first_quad_ip_seq

function first_quad_ip_seq::new(string name = "first_quad_ip_seq"); 
	super.new(name); 
endfunction

task first_quad_ip_seq::body();
	repeat(20) begin
		req= cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle inside {[17'd1 : 17'd89]};}); 
		finish_item(req);
	end
endtask

//second_quad_ip_seq
class second_quad_ip_seq extends cordic_base_sequence;
    `uvm_object_utils(second_quad_ip_seq)
	
	extern function new(string name = "second_quad_ip_seq");
	extern task body();
endclass : second_quad_ip_seq

function second_quad_ip_seq::new(string name = "second_quad_ip_seq"); 
	super.new(name); 
endfunction

task second_quad_ip_seq::body();
	repeat(20) begin
		req= cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle inside {[17'd91 : 17'd179]};}); 
		finish_item(req);
	end
endtask

//third_quad_ip_seq
class third_quad_ip_seq extends cordic_base_sequence;
    `uvm_object_utils(third_quad_ip_seq)

	extern function new(string name = "third_quad_ip_seq");
	extern task body();
endclass : third_quad_ip_seq

function third_quad_ip_seq::new(string name = "third_quad_ip_seq"); 
	super.new(name); 
endfunction

task third_quad_ip_seq::body(); 
	repeat(20) begin
		req= cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle inside {[17'd181 : 17'd269]};}); 
		finish_item(req);
	end
endtask

//fourth_quad_ip_seq
class fourth_quad_ip_seq extends cordic_base_sequence;
    `uvm_object_utils(fourth_quad_ip_seq)
	
	extern function new(string name = "fourth_quad_ip_seq");
	extern task body();
endclass : fourth_quad_ip_seq

function fourth_quad_ip_seq::new(string name = "fourth_quad_ip_seq"); 
	super.new(name); 
endfunction

task fourth_quad_ip_seq::body();
	repeat(20) begin
		req= cordic_sequence_item::type_id::create("req");
		start_item(req);
		assert (req.randomize() with {Input_angle inside {[17'd271 : 17'd359]};}); 
		finish_item(req);
	end
endtask

// std_ip_seq : standard angles (fixed-point scaled)
class std_ip_seq extends cordic_base_sequence;
  `uvm_object_utils(std_ip_seq)

  extern function new(string name = "std_ip_seq");
  extern task body();
endclass : std_ip_seq

function std_ip_seq::new(string name = "std_ip_seq");
  super.new(name);
endfunction

task std_ip_seq::body();


  repeat(300) begin
    req = cordic_sequence_item::type_id::create("req");
    start_item(req);
	assert(req.randomize() with {Input_angle inside {
17'd568 ,17'd2119 ,17'd2617 ,17'd3540 ,17'd4656 ,17'd4782 ,17'd5979 ,17'd6543 ,17'd6697 ,17'd7622 ,17'd7675 ,17'd9110 ,17'd10055 ,17'd11107 ,17'd11928 ,17'd12312 ,17'd12563 ,17'd14360 ,17'd14507 ,17'd16059 ,17'd17554 ,17'd16061 ,17'd18718 ,17'd18880 ,17'd19030 ,17'd20175 ,17'd20457 ,17'd20555 ,17'd21859 ,17'd26640 ,17'd27934 ,17'd29980 ,17'd28921 ,17'd30075 ,17'd31320 ,17'd32014 ,17'd31358 ,17'd32089 ,17'd33476 ,17'd34064 ,17'd33491 ,17'd36726 ,17'd36902 ,17'd37715 ,17'd40012 ,17'd38557 ,17'd44013 ,17'd44466 ,17'd45311 ,17'd46950 ,17'd48612 ,17'd50833 ,17'd50975 ,17'd52937 ,17'd53538 ,17'd53812 ,17'd54021 ,17'd55867 ,17'd56281 ,17'd57780 ,17'd60986 ,17'd61550 ,17'd61628 ,17'd61881 ,17'd62987 ,17'd62543 ,17'd64165 ,17'd65633 ,17'd68203 ,17'd70438 ,17'd72892 ,17'd72767 ,17'd73424 ,17'd75047 ,17'd75109 ,17'd75354 ,17'd78318 ,17'd79366 ,17'd79398 ,17'd79498 ,17'd79795 ,17'd80829 ,17'd82581 ,17'd83220 ,17'd85314 ,17'd83947 ,17'd85695 ,17'd88851 ,17'd89168 ,17'd91333 ,17'd93609 ,17'd94901 ,17'd92117 ,17'd96716 ,17'd97682 ,17'd97870 ,17'd99406 ,17'd99813 ,17'd99846 ,17'd101594 };});
    finish_item(req);
  end
endtask