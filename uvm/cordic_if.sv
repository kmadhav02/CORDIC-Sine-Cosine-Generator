interface cordic_if(input logic Clk, Reset);
    logic [16:0] Input_angle;
    logic signed [15:0] Cos_out;
    logic signed [15:0] Sin_out;

   
    clocking drv_cb @(posedge Clk);
        default input #1ns output #1ns; 
        output  Input_angle;             
        input  Cos_out;
		input Sin_out;                
    endclocking

   
    clocking mon_cb @(posedge Clk);
        default input #1ns output #1ns;
        input Input_angle;              
        input Cos_out;
		input Sin_out;                 
    endclocking

    modport DRV (clocking drv_cb, input Clk, Reset);
    modport MON (clocking mon_cb, input Clk, Reset);

endinterface