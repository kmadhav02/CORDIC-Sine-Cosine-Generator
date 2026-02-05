module cordic_top();
	import uvm_pkg::*; 
	import pkg::*;
	bit Clk;
	bit Reset;
	
	initial begin Clk = 0; forever #5 Clk = ~Clk; end
	initial begin 
		@(posedge Clk) Reset = 1;
		@(posedge Clk) Reset = 0;
    end
	
	cordic_if cif(Clk,Reset); 
	CORDIC_TOP CT(
					.Clk(cif.Clk),
					.Reset(cif.Reset),
					.Input_angle(cif.Input_angle),
					.Cos_out(cif.Cos_out),
					.Sin_out(cif.Sin_out)
				);
	
	initial begin
		uvm_config_db#(virtual cordic_if)::set(null, "*", "cordic_if", cif);
		run_test("std_ip_test");
	end
endmodule