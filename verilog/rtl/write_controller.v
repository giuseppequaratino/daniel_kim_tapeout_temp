module write_controller(clk_in, clk_in_main, addr, s_data, p_data, clk_read, clk_write, reset);
	parameter S1_LENGTH = 3444;
	input clk_in, clk_in_main;
	input [7:0] s_data;
	input wire reset;

	output reg [11:0] addr;
	output reg [2047:0] p_data;
	output reg clk_read;
	output reg clk_write;

	wire clk_read_wire, clk_write_wire;
	wire [2047:0] p_data_wire;

	/*
	initial begin
		addr = 0;
	end
	*/

	always @(posedge clk_in) begin
		if(reset) begin
			addr = 0;
			clk_read = 1'b0;
			clk_write = 1'b0;
		end
	end

	s2p s(.clk(clk_in), .clk_in(clk_in_main), .s_data(s_data), .p_data(p_data_wire), .clk_read(clk_read_wire), .clk_write(clk_write_wire));
	
	always @(clk_read_wire) begin
		clk_read = clk_read_wire;
	end	
	always @(clk_write_wire) begin
		clk_write = clk_write_wire;
	end	
	always @(p_data_wire) begin
		p_data = p_data_wire;
	end	

	always @(posedge clk_write) begin
		addr <= addr + 1;
		if (addr == S1_LENGTH-1)begin
			addr <= 12'b000000000000;
		end
	end
endmodule
