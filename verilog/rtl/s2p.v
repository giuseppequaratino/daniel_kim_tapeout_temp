module s2p (input clk, input clk_in, input wire[7:0] s_data, output reg[2047:0] p_data, output reg clk_read, output reg clk_write);
reg[3:0] i=0;
reg[3:0] row=0;
reg[9:0] count=0;


initial begin
	p_data = 2048'b0;
	clk_read = 1'b0;
	clk_write = 1'b0;
end

always @(posedge clk) begin
	p_data <= {p_data[2039:0], s_data};
	clk_read <= 1'b0;
	count <= count + 1'b1;
end

always @(posedge clk_in) begin
	clk_write <= 1'b0;
	clk_read <= 1'b0;
	
end

always @(negedge clk) begin
	if (count == 255) begin
		clk_read <= 1'b1;
	end
	if (count == 256) begin
		count <= 0;
		clk_write <= 1'b1;
	end
end

endmodule
