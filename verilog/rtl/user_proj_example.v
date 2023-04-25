// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [15:0] io_in,
    output [15:0] io_out,
    output [15:0] io_oeb,

    // IRQ
    output [2:0] irq
);

        parameter FRAME_WIDTH = 2048;
        
	// INPUTS AND OUTPUTS
	reg clk_in = wb_clk_i;
        reg [7:0] s_data = io_in[7:0];
	wire [15:0] motion_vec = io_out[15:0];
        
	//TOP MODULE
	wire clk0, clk1, clk2;
        wire clk_read, clk_write;
        reg csb0 = 0;
        reg csb1 = 1;
        reg  web0;
        reg [3:0] wmask0;
        wire [FRAME_WIDTH-1:0] dout0, dout1;
        wire [11:0] addr0, addr1;
        wire [FRAME_WIDTH-1:0] p_data; // parallelized data
        wire [FRAME_WIDTH-1:0] t_data; // transferred data
        wire [FRAME_WIDTH-1:0] dout_A, dout_B; // data
        reg [7:0] count = 8'b0;
        wire [2047:0] block_A;
        wire [18431:0] block_B;
        wire [11:0] addrA, addrB;
        wire csbA, csbB;

        clock_controller cc(.clk_in(clk_in), .csbA(csbA), .csbB(csbB), .clk0(clk0), .clk1(clk1), .clk2(clk2), .addr1(addrA), .addr2(addrB), .reset(wb_rst_i));
        write_controller wc_A(.clk_in(clk0), .clk_in_main(clk_in), .addr(addr0), .s_data(s_data), .p_data(p_data), .clk_read(clk_read), .clk_write(clk_write), .reset(wb_rst_i));
        //transfer_controller wc_B(.clk_in(clk_write), .addr(addr1));
        sram sram_A(.clk0(clk_write), .csb0(csb0), .web0(web0), .wmask0(wmask0), .addr0(addr0), .din0(p_data), .dout0(dout0), .clk1(clk_read), .csb1(csb0), .addr1(addr0), .dout1(t_data), .clk2(clk1), .csb2(csb0), .addr2(addrA), .dout2(dout_A));
        sram sram_B(.clk0(clk_write), .csb0(csb0), .web0(web0), .wmask0(wmask0), .addr0(addr0), .din0(t_data), .dout0(dout0), .clk1(clk_read), .csb1(csb1), .addr1(addr0), .dout1(dout0), .clk2(clk1), .csb2(csb0), .addr2(addrB), .dout2(dout_B));
        processor_block p_block(.clk(clk2), .clk1(clk1), .block_A(dout_A), .block_B(dout_B), .motion_vec(motion_vec), .reset(wb_rst_i));

endmodule

`default_nettype wire
