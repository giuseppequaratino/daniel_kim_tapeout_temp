module processor_block 
	#(parameter S1_LENGTH = 9)
	(input wire clk, input wire clk1, input wire [2047:0]block_A, input wire [2047:0]block_B, output reg [15:0] motion_vec, input wire reset);

wire [15:0] sae [32:0];
reg [17423:0] saeReg; // 33*33*16
reg [2047:0] block_A_reg;
reg [18431:0]block_B_reg;// 9*2048
wire [7:0] search_window [47:0][47:0];

//wire [7:0] block_B_wire [8447:0];
wire [2047:0] block_B_wire [32:0];
genvar row, col, i, j, k;
reg [31:0] count;

reg [7:0] col_count;
reg [7:0] r, c;
reg [15:0] min;
reg trigger;

always @(posedge clk) begin
	if(reset) begin
		block_B_reg = 0;
		block_A_reg = 0;
		count = 0;

		col_count = 0;
		min = 16'b1111111111111111;
		trigger = 1'b0;
	end
end

/*
always @(*) begin
	search_window = block_B_reg;
end
*/


	generate
        for(i = 0 ; i < 48 ; i = i + 1) begin
            for(j = 0 ; j < 48 ; j = j + 1) begin
                assign search_window[i][j] = block_B_reg[(8*(i+1)+384*j-1) : (8*i+384*j)];
            end
        end
	endgenerate


generate
	for (col = 0; col<33; col = col+1) begin
		for (i=0; i<16; i=i+1) begin
			for (j=0; j<16; j=j+1) begin
				assign block_B_wire[col][16*i+j] = search_window[i][col+j];
			end
		end
	end
endgenerate


generate
	for (row=0; row<33; row=row+1) begin
		processor p(clk, block_A_reg, block_B_wire[row], sae[row]);
	end
endgenerate


always @(negedge trigger) begin
	min = 16'b1111111111111111;
	for (r=0;r<33;r=r+1) begin
		for (c=0;c<33;c=c+1) begin
			if (saeReg[15:0] < min) begin
				min = saeReg[15:0];
				motion_vec[7:0] = r;
				motion_vec[15:8] = c;

				/*
				$display("Value of min: %h", min);
				*/
			end
			saeReg = {16'b1, saeReg[17423:16]};
		end
	end
	//$display("Value of motionvector[0]: %d", motion_vec[0]);
	//$display("Value of motionvector[1]: %d", motion_vec[1]);

end

always @(posedge clk) begin
	trigger = 1'b0;
	col_count <= col_count+1;
		/*
		for (r=0; r<33;r=r+1) begin
			$display("SAE: %d", sae[r]);
		end
		*/
//sae[15], sae[14], sae[13], sae[12], sae[11], sae[10], sae[9], sae[8], sae[7], sae[6] ,sae[5], sae[4], sae[3], sae[2], sae[1], sae[0]
		
		saeReg <= {saeReg[16894:0], sae[15], sae[14], sae[13], sae[12], sae[11], sae[10], sae[9], sae[8], sae[7], sae[6] ,sae[5], sae[4], sae[3], sae[2], sae[1], sae[0]};
		block_B_reg <= {48'b0, block_B_reg[18431:48]};
		trigger = 1'b0;

		/*
		$display("Value of count: %d", col_count);	
		$display("Value of block_B_reg[0]: %h", block_B_reg[0]);
		$display("Value of block_B_reg[1]: %h", block_B_reg[1]);
		$display("Value of block_B_reg[2]: %h", block_B_reg[2]);
		$display("Value of block_A_reg: %h", block_A_reg);
		$display("Value of block_B_reg: %h", block_B_reg);
		$display("------------------");	
		*/
end

always @(negedge clk) begin
	if (col_count == 33) begin
		trigger = 1'b1;
		col_count <= 0;
	end
end

always @(posedge clk1) begin
	count <= count + 1; 
	block_B_reg <= {block_B_reg[16383:0], block_B};
	block_A_reg <= block_A;
	if (count == S1_LENGTH) begin
		count <= 0;
	end
end

always @(negedge clk1) begin
end

endmodule
