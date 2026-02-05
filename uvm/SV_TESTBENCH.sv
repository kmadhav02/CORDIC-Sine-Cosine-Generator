interface cordic_intf(input bit clk);
    logic rst;
    logic [16:0] angle;
    logic signed [15:0] cos_out;
    logic signed [15:0] sin_out;

    clocking drv_cb @ (posedge clk);
        output rst;
        output angle;
    endclocking
   
    clocking mon_cb @ (posedge clk);
        input cos_out;
        input sin_out;
    endclocking
   
    modport drv_mp(clocking drv_cb, input clk, output rst, output angle); 
    modport mon_mp(clocking mon_cb, input clk);
endinterface


// DRIVER - 100 Tests

class cordic_driver;
    virtual cordic_intf.drv_mp vif;
    string name;
    mailbox drv_mbx;
    const int NUM_TESTS = 100;
    const real PI = 3.14159265359;
   
    function new(string name = "driver");
        this.name = name;
    endfunction
   
    function void build();
        this.drv_mbx = new(1024);
    endfunction

    function bit [16:0] deg_to_fixed(real deg);
        real radians, normalized;
        bit [16:0] result;
        radians = deg * PI / 180.0;
        normalized = radians / (2.0 * PI);
        result = $rtoi(normalized * 102944.0);
        return result;
    endfunction
   
    task run();
        real angle_deg;
        bit [16:0] angle_fixed;
        
        $display("\n+============================================================+");
        $display("|          CORDIC VERIFICATION - 100 TEST VECTORS            |");
        $display("+============================================================+\n");
       
        vif.rst = 1;
        repeat(5) @(posedge vif.clk);
        vif.rst = 0;
        repeat(2) @(posedge vif.clk);
       
        $display(">> Applying %0d test vectors (0 to 360 degrees)...\n", NUM_TESTS);
       
        for (int i = 0; i < NUM_TESTS; i++) begin
            angle_deg = (i * 360.0) / NUM_TESTS;
            angle_fixed = deg_to_fixed(angle_deg);
            
            vif.angle = angle_fixed;
            drv_mbx.put(i);
            
            if (i % 10 == 0) begin
                $display("   [Test %3d] Angle: %6.2f deg (0x%05h)", i, angle_deg, angle_fixed);
            end
            
            repeat(20) @(posedge vif.clk);
        end
       
        vif.angle = 0;
        repeat(50) @(posedge vif.clk);
        $display("\n>> All test vectors applied.\n");
    endtask
endclass


// MONITOR

class cordic_monitor;
    virtual cordic_intf.mon_mp vif;
    string name;
    mailbox mon_mbx;
    int cnt = 0;
    const int NUM_TESTS = 100;
   
    function new(string name = "monitor");
        this.name = name;
    endfunction
   
    task run();
        bit [31:0] data;
        int capture_cycle;
        int captures = 0;
        
        forever begin
            @(posedge vif.clk);

            capture_cycle = 24 + (captures * 20);
            
            if (captures < NUM_TESTS && cnt == capture_cycle) begin
                data = {vif.mon_cb.cos_out, vif.mon_cb.sin_out};
                mon_mbx.put(data);
                captures++;
            end
            cnt++;
        end
    endtask
endclass


// SCOREBOARD WITH STATISTICS

class cordic_scoreboard;
    string name;
    mailbox drv_mbx, mon_mbx;
    int total = 0, pass = 0;
    const int TOLERANCE = 50;
    const real SCALE_FACTOR = 32767.0;
    const real PI = 3.14159265359;
    const int NUM_TESTS = 100;
    

    real max_cos_error = 0.0;
    real max_sin_error = 0.0;
    real avg_cos_error = 0.0;
    real avg_sin_error = 0.0;

    function new(string name = "scoreboard");
        this.name = name;
    endfunction

    function int abs_diff(int a, int b);
        int res = a - b;
        return (res < 0) ? -res : res;
    endfunction
    
    function real to_decimal(shortint fixed_val);
        real result;
        result = $itor(fixed_val) / SCALE_FACTOR;
        return result;
    endfunction

    function void calc_expected(int test_id, output real exp_cos, output real exp_sin);
        real angle_deg, angle_rad;
        angle_deg = (test_id * 360.0) / NUM_TESTS;
        angle_rad = angle_deg * PI / 180.0;
        exp_cos = $cos(angle_rad);
        exp_sin = $sin(angle_rad);
    endfunction

    task run();
        int id;
        bit [31:0] data;
        shortint act_cos_int, act_sin_int;
        real act_cos, act_sin, exp_cos, exp_sin;
        real cos_error, sin_error;
        int cos_diff_lsb, sin_diff_lsb;
        shortint exp_cos_int, exp_sin_int;
        
        $display("+==============================================================================+");
        $display("|                        VERIFICATION RESULTS                                  |");
        $display("+==============================================================================+");
        $display("| Test | Angle  |   Expected (cos, sin)   |    Actual (cos, sin)    | Status |");
        $display("+------------------------------------------------------------------------------+");
        
        forever begin
            drv_mbx.get(id);
            mon_mbx.get(data);
            
            act_cos_int = data[31:16];
            act_sin_int = data[15:0];
            

            act_cos = to_decimal(act_cos_int);
            act_sin = to_decimal(act_sin_int);
            

            calc_expected(id, exp_cos, exp_sin);

            exp_cos_int = $rtoi(exp_cos * SCALE_FACTOR);
            exp_sin_int = $rtoi(exp_sin * SCALE_FACTOR);
            

            cos_error = (act_cos - exp_cos);
            sin_error = (act_sin - exp_sin);
            if (cos_error < 0) cos_error = -cos_error;
            if (sin_error < 0) sin_error = -sin_error;
            
            cos_diff_lsb = abs_diff(exp_cos_int, act_cos_int);
            sin_diff_lsb = abs_diff(exp_sin_int, act_sin_int);
            

            if (cos_error > max_cos_error) max_cos_error = cos_error;
            if (sin_error > max_sin_error) max_sin_error = sin_error;
            avg_cos_error += cos_error;
            avg_sin_error += sin_error;

            total++;
            

            if (cos_diff_lsb <= TOLERANCE && sin_diff_lsb <= TOLERANCE) begin
                pass++;
                if (id < 10 || id >= (NUM_TESTS - 10) || id % 10 == 0) begin
                    $display("| %3d  | %5.1f  | (%7.5f,%7.5f) | (%7.5f,%7.5f) |  PASS  |", 
                             id, (id * 360.0) / NUM_TESTS, exp_cos, exp_sin, act_cos, act_sin);
                end
            end else begin
                pass = pass;
                $display("| %3d  | %5.1f  | (%7.5f,%7.5f) | (%7.5f,%7.5f) | *FAIL* |", 
                         id, (id * 360.0) / NUM_TESTS, exp_cos, exp_sin, act_cos, act_sin);
                $display("|      |        |                         | Error: (%0d,%0d) LSBs    |        |",
                         cos_diff_lsb, sin_diff_lsb);
            end
        end
    endtask

    function void report();
        real pass_rate;
        pass_rate = (total > 0) ? ($itor(pass) / $itor(total)) * 100.0 : 0.0;
        
        if (total > 0) begin
            avg_cos_error = avg_cos_error / total;
            avg_sin_error = avg_sin_error / total;
        end
        
        $display("+==============================================================================+");
        $display("|                          FINAL SUMMARY                                       |");
        $display("+==============================================================================+");
        $display("|  Total Tests       : %3d                                                      |", total);
        $display("|  Passed            : %3d                                                      |", pass);
        $display("|  Failed            : %3d                                                      |", total - pass);
        $display("|  Pass Rate         : %6.2f%%                                                 |", pass_rate);
        $display("|  Tolerance         : +/-%0d LSBs                                              |", TOLERANCE);
        $display("+------------------------------------------------------------------------------+");
        $display("|  ACCURACY STATISTICS:                                                        |");
        $display("|  Max Cosine Error  : %10.7f                                             |", max_cos_error);
        $display("|  Max Sine Error    : %10.7f                                             |", max_sin_error);
        $display("|  Avg Cosine Error  : %10.7f                                             |", avg_cos_error);
        $display("|  Avg Sine Error    : %10.7f                                             |", avg_sin_error);
        
        if (pass == total) begin
            $display("+------------------------------------------------------------------------------+");
            $display("|                                                                              |");
            $display("|                    *** ALL TESTS PASSED ***                                  |");
            $display("|                                                                              |");
        end else begin
            $display("+------------------------------------------------------------------------------+");
            $display("|                                                                              |");
            $display("|                    *** SOME TESTS FAILED ***                                 |");
            $display("|                                                                              |");
        end
        
        $display("+==============================================================================+\n");
    endfunction
endclass


// ENVIRONMENT

class environment;
    cordic_driver drv;
    cordic_monitor mon;
    cordic_scoreboard sb;
    virtual cordic_intf vif;

    function new(virtual cordic_intf vif);
        this.vif = vif;
        drv = new("DRIVER");
        mon = new("MONITOR");
        sb  = new("SCOREBOARD");
        drv.build();
        mon.mon_mbx = new();
        sb.mon_mbx = mon.mon_mbx;
        sb.drv_mbx = drv.drv_mbx;
    endfunction

    task run();
        drv.vif = vif;
        mon.vif = vif;
        
        fork
            drv.run();
            mon.run();
            sb.run();
        join_any
        
        repeat(500) @(posedge vif.clk);
        sb.report();
    endtask
endclass


// TOP LEVEL

module cordic_tb_top;
    bit Clk;
    always #5 Clk = ~Clk;

    cordic_intf intf(Clk);

    CORDIC_TOP #(.STAGES(16)) dut (
        .Clk         (intf.clk),
        .Reset       (intf.rst),
        .Input_angle (intf.angle),
        .Cos_out     (intf.cos_out),
        .Sin_out     (intf.sin_out)
    );

    initial begin
        environment env;
        env = new(intf);
        env.run();
        $finish;
    end
endmodule