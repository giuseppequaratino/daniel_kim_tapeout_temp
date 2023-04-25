module processor (input wire clk, input wire [2047:0] i_current_block, input wire [2047:0] i_search_window, output wire [15:0] o_sae_result); 
// local variables 
reg [7:0] idx,jdx; 
wire [7:0] current_block [0:15] [0:15]; 
wire [7:0] search_window [0:15] [0:15]; 
wire[7:0] sae_result [0:15] [0:15]; 
reg [15:0] sae_accumulator; 
// genvar statement 
genvar i,j; 
generate
	for(i = 0 ; i < 15 ; i = i + 1) begin 
		for(j = 0 ; j < 15 ; j = j + 1) begin 
			assign current_block[i][j] = i_current_block[(8*(i+1)+128*j-1) : (8*i+128*j)]; 
			assign search_window[i][j] = i_search_window[(8*(i+1)+128*j-1) : (8*i+128*j)]; 
			assign sae_result[i][j] = (current_block[i][j] > search_window[i][j]) ? (current_block[i][j] - search_window[i][j]) : (search_window[i][j] - current_block[i][j]); 
		end 
	end
endgenerate
/*
always @(posedge clk) begin
	$display("current_block: %d", current_block);
	$display("search_window: %d", search_window);
end

always @(*) begin 
sae_accumulator = 15'b0; 
for(idx = 0; idx < 15 ; idx = idx + 1) begin 
	for(jdx = 0; jdx < 15 ; jdx = jdx + 1) begin 
		sae_accumulator = sae_accumulator + sae_result[idx][jdx]; 
	end 
end 
end 
always @(sae_accumulator) begin
	assign o_sae_result = sae_accumulator; 
end
*/

always @(posedge clk) begin
        sae_accumulator = 15'b0;
        for(idx = 0; idx < 15 ; idx = idx + 1) begin
            for(jdx = 0; jdx < 15 ; jdx = jdx + 1) begin
                sae_accumulator = sae_accumulator + sae_result[idx][jdx];
            end
        end
end
  
assign o_sae_result = sae_accumulator;

endmodule
