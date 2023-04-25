module clock_controller(clk_in, csbA, csbB, clk0, clk1, clk2, addr1, addr2, reset);
	parameter S0_LENGTH = 256*3444; // 3444
	parameter S1_LENGTH = 10; // 9
	parameter S2_LENGTH = 33; // 33
	parameter UPPER_LENGTH = 3200; // 3200
	input wire clk_in;
	input wire reset;
	output reg clk0, clk1, clk2;
	output reg csbA, csbB;
	output reg [11:0]addr1;
	output reg [11:0]addr2;
	reg [31:0] count0, count_upper, count1, count2, count_length, count_length_2;
	reg [1:0] state;
	reg en0, en1, en2;

	/*
	initial begin
		state = 2'b0;
		count0 = 32'b0;
		count_upper = 32'b0;
		count_length = 32'b0;
		count_length_2 = 32'b0;
		count1 = 32'b0;
		count2 = 32'b0;
		csbA = 1'b0;
		csbB = 1'b0;
	end
	*/

	always @(clk_in, en0) begin
		clk0 = en0 & clk_in;
	end	
	always @(clk_in, en1) begin
		clk1 = en1 & clk_in;
	end	
	always @(clk_in, en2) begin
		clk2 = en2 & clk_in;
	end

	always @(posedge clk_in) begin
		if(reset) begin
			state = 2'b0;
			count0 = 32'b0;
			count_upper = 32'b0;
			count_length = 32'b0;
			count_length_2 = 32'b0;
			count1 = 32'b0;
			count2 = 32'b0;
			csbA = 1'b0;
			csbB = 1'b0;

			addr1 = 83;
			addr2 = 12'b000000000000;
		end else begin

		case (state)
			2'b00: begin // write to sram
				count0 <= count0 + 32'b1;
			end
			2'b01: begin// read in values to processors 
				count1 <= count1 + 32'b1;
			end
			2'b11: begin // calculate
				count2 <= count2 + 32'b1;
			end
		endcase
		end
	end

	always @(negedge clk_in) begin
		case (state)
			2'b00: begin // write to sram
				csbA <= 1'b1;
				csbB <= 1'b1;
				if (count0 == S0_LENGTH) begin	
					count0 <=0;
					state <= 2'b01;
				end
			end
			2'b01: begin // read in values to processors 
				csbA <= 1'b0;
				csbB <= 1'b0;



				if (count1 == S1_LENGTH) begin
					count1 <=0;
					count_length <= 0;
					count_upper <= count_upper + 32'b1;
					state <= 2'b11;
				end
				else begin
					if (count1 >1) begin
						if (count_length == 2) begin
							count_length <= 0;
							addr2 <= addr2 + 80;
						end
						else begin
							if (count1 < S1_LENGTH) begin
								addr2 <= addr2 + 1;
							end
							count_length <= count_length + 12'b1;
						end
					end
				end
				
			end
			2'b11: begin // calculate
				if (count2 == S2_LENGTH) begin
					count2 <= 32'b0;
					if (count_upper == UPPER_LENGTH) begin
						count_upper <= 0;
						state <= 2'b00;
						addr1 <= 83;
						addr2 <= 12'b0;
					end
					else begin
						if (count_length_2 == 80) begin
							count_length_2 <= 0;
							addr1 <= addr1 + 3;
							addr2 <= addr2 -163;
						end
						else begin
							count_length_2 <= count_length_2+1;
							addr1 <= addr1 + 1;
							addr2 <= addr2 - 165;
						end
						state <= 2'b01;
						
					end
				end
			end
		endcase
	end
	

	always @(state) begin
		case (state)
			2'b00: begin // write to sram
				en0 = 1;
				en1 = 0;
				en2 = 0;
			end
			2'b01: begin// read in values to processors 
				en0 = 0;
				en1 = 1;
				en2 = 0;
			end
			2'b11: begin // calculate
				en0 = 0;
				en1 = 0;
				en2 = 1;
			end
		endcase	
	end
endmodule
