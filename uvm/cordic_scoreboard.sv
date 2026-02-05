class cordic_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(cordic_scoreboard)
    
	cordic_env_config env_cfg;
    
	uvm_analysis_export#(cordic_sequence_item) ip2sb;
	uvm_analysis_export#(cordic_sequence_item) op2sb;
    
	uvm_tlm_analysis_fifo #(cordic_sequence_item) cordic_ip_fifo;
	uvm_tlm_analysis_fifo #(cordic_sequence_item) cordic_op_fifo;
	virtual cordic_if.DRV vif;
	cordic_sequence_item ip_cordic, op_cordic;
    
	int tolerance = 15;
	int golden_cos[int];
	int golden_sin[int];
	int matches1 = 0;
	int mismatches = 0;
	real ANGLE_RADIANS;
    
	extern function new(string name="cordic_scoreboard", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern function void compare(cordic_sequence_item ip_cordic,cordic_sequence_item op_cordic);
	extern function void load_golden_reference();
	extern function void report_phase(uvm_phase phase);
endclass : cordic_scoreboard

function cordic_scoreboard::new(string name="cordic_scoreboard", uvm_component parent);
	super.new(name, parent);
	cordic_ip_fifo = new("cordic_ip_fifo", this);
	cordic_op_fifo = new("cordic_op_fifo", this);
endfunction

function void cordic_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
    
	if(!uvm_config_db #(cordic_env_config)::get(null, get_full_name(), "env_cfg", env_cfg))
		`uvm_fatal("CONFIG", "Cannot get() env_cfg, have you set() it?")
    
	ip2sb = new("ip2sb", this);
	op2sb = new("op2sb", this);
	vif = env_cfg.iagt_cfg.vif;
	load_golden_reference();
endfunction

function void cordic_scoreboard::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	ip2sb.connect(cordic_ip_fifo.analysis_export);
	op2sb.connect(cordic_op_fifo.analysis_export);
endfunction

task cordic_scoreboard::run_phase(uvm_phase phase);
	fork
		forever begin
			cordic_ip_fifo.get(ip_cordic);
			`uvm_info(get_type_name(), $sformatf("IP: Angle=%0d", ip_cordic.Input_angle), UVM_HIGH)
		end
    
		forever begin
			cordic_op_fifo.get(op_cordic);
			`uvm_info(get_type_name(), $sformatf("OP: Angle=%0d, Cos=%0d, Sin=%0d", 
				op_cordic.Input_angle, $signed(op_cordic.Cos_out), $signed(op_cordic.Sin_out)), UVM_HIGH)
			compare(ip_cordic,op_cordic);
			repeat(20) @(vif.drv_cb);
		end
	join_none
endtask

function void cordic_scoreboard::compare(cordic_sequence_item ip_cordic,cordic_sequence_item op_cordic);
	int expected_cos, expected_sin;
	int cos_min, cos_max, sin_min, sin_max;
	int cos_condition, sin_condition;

	if (!golden_cos.exists(op_cordic.Input_angle)) begin
		`uvm_error(get_type_name(), $sformatf("NO GOLDEN DATA for angle=%0d (0x%0h)", 
					op_cordic.Input_angle, op_cordic.Input_angle))
		`uvm_info(get_type_name(), $sformatf("Available angles in golden reference: %0d entries", 
					golden_cos.num()), UVM_LOW)
        
		if (golden_cos.num() > 0) begin
			int keys[$];
			int key;
			keys = golden_cos.find_index with (1);
			`uvm_info(get_type_name(), "First few available angles:", UVM_LOW)
			foreach(keys[i]) begin
				if (i < 5) begin
					`uvm_info(get_type_name(), $sformatf("  Angle[%0d] = %0d", i, keys[i]), UVM_LOW)
				end
			end
		end
        return;
	end

    expected_cos = golden_cos[op_cordic.Input_angle];
    expected_sin = golden_sin[op_cordic.Input_angle];

    `uvm_info(get_type_name(), $sformatf("Expected: Cos=%0d, Sin=%0d", expected_cos, expected_sin), UVM_DEBUG)

    cos_min = expected_cos - tolerance;
    cos_max = expected_cos + tolerance;
    sin_min = expected_sin - tolerance;
    sin_max = expected_sin + tolerance;

	sin_condition =( (($signed(op_cordic.Sin_out) - sin_min) >= 0) && (($signed(op_cordic.Sin_out) - sin_max <= 0)) );
	cos_condition =( (($signed(op_cordic.Cos_out) - cos_min) >= 0) && (($signed(op_cordic.Cos_out) - cos_max <= 0)) );
	if( sin_condition && cos_condition)	begin
        matches1++;
        `uvm_info(get_type_name(), 
                 $sformatf("PASS [%0d]: Angle=%0d | Cos=%0d (exp=%0d, err=%0d) | Sin=%0d (exp=%0d, err=%0d)", 
                          matches1, op_cordic.Input_angle,
                          $signed(op_cordic.Cos_out), expected_cos, cos_condition,
                          $signed(op_cordic.Sin_out), expected_sin, sin_condition), UVM_MEDIUM)
    end else begin
        mismatches++;
        `uvm_error(get_type_name(), 
                  $sformatf("FAIL [%0d]: Angle=%0d | Cos=%0d (exp=%0d, err=%0d, range:[%0d:%0d]) | Sin=%0d (exp=%0d, err=%0d, range:[%0d:%0d])", 
                           mismatches, op_cordic.Input_angle,
                           $signed(op_cordic.Cos_out), expected_cos, cos_condition, cos_min, cos_max,
                           $signed(op_cordic.Sin_out), expected_sin, sin_condition, sin_min, sin_max))
    end
endfunction

function void cordic_scoreboard::load_golden_reference();
    int file;
    string line;
    int angle, cos_val, sin_val;
    int status;
    int line_count = 0;
    int line_num = 0;
    int empty_lines = 0;
    
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    `uvm_info(get_type_name(), "Loading Golden Reference from CSV...", UVM_LOW)

    file = $fopen("cordic.csv", "r");
    if (file == 0) begin
        `uvm_fatal(get_type_name(), "Cannot open cordic.csv")
    end
    
    `uvm_info(get_type_name(), "File opened successfully", UVM_LOW)

    while (!$feof(file)) begin
        status = $fgets(line, file);
        line_num++;
        if (status == 0) break;
        if (line_num == 1) begin
            `uvm_info(get_type_name(), $sformatf("Skipping header: %s", line), UVM_DEBUG)
            continue;
        end
        if (line == "" || line == "\n" || line == " \n") begin
            empty_lines++;
            continue;
        end
        if ($sscanf(line, "%d,%d,%d", angle, cos_val, sin_val) == 3) begin
            golden_cos[angle] = cos_val;
            golden_sin[angle] = sin_val;
            line_count++;
            if (line_count <= 5) begin
                `uvm_info(get_type_name(), 
                         $sformatf("Line %0d: angle=%0d, cos=%0d, sin=%0d", 
                                  line_num, angle, cos_val, sin_val), UVM_DEBUG)
            end
        end
        else if (line_count > 0 && empty_lines > 10) begin
            `uvm_info(get_type_name(), 
                     $sformatf("Stopping read after %0d consecutive empty lines", empty_lines), UVM_LOW)
            break;
        end
    end
    
    $fclose(file);
    
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Successfully loaded %0d golden entries", line_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Total lines read: %0d", line_num), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Empty lines skipped: %0d", empty_lines), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Associative array size: %0d", golden_cos.num()), UVM_LOW)
    `uvm_info(get_type_name(), "========================================", UVM_LOW)

    if (line_count == 0) begin
        `uvm_fatal(get_type_name(), "No valid entries loaded from CSV!")
    end
    if (golden_cos.num() > 0) begin
        int keys[$];
        keys = golden_cos.find_index with (1);
        `uvm_info(get_type_name(), $sformatf("Sample of loaded data (showing first 5 of %0d):", keys.size()), UVM_LOW)
        foreach(keys[i]) begin
            if (i < 5) begin
                `uvm_info(get_type_name(), 
                         $sformatf("  Angle=%0d (0x%0h), Cos=%0d, Sin=%0d", 
                                  keys[i], keys[i], golden_cos[keys[i]], golden_sin[keys[i]]), UVM_LOW)
            end
        end
    end
endfunction

function void cordic_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    `uvm_info(get_type_name(), "      CORDIC SCOREBOARD REPORT", UVM_LOW)
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Total Tests:  %0d", matches1 + mismatches), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Passed:       %0d", matches1), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Failed:       %0d", mismatches), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Tolerance:    ±%0d LSB", tolerance), UVM_LOW)
    
    if (matches1 + mismatches > 0) begin
        real pass_rate = (real'(matches1) / real'(matches1 + mismatches)) * 100.0;
        `uvm_info(get_type_name(), $sformatf("Pass Rate:    %.2f%%", pass_rate), UVM_LOW)
    end
    
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    
    if (mismatches == 0 && matches1 > 0)
        `uvm_info(get_type_name(), "*** ALL TESTS PASSED ***", UVM_LOW)
    else if (matches1 == 0)
        `uvm_error(get_type_name(), "*** NO TESTS EXECUTED ***")
    else
        `uvm_error(get_type_name(), "*** SOME TESTS FAILED ***")
endfunction 



