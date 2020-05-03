/*  This file is part of JTCONTRA.
    JTCONTRA program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTCONTRA program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTCONTRA.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 03-05-2020 */

// Equivalent to KONAMI 007593

module jtcontra_colmix(
    input               rst,
    input               clk,
    input               clk24,
    input               pxl2_cen,
    input               pxl_cen,
    input               LHBL,
    input               LVBL,
    output              LHBL_dly,
    output              LVBL_dly,
    // CPU      interface
    input               pal_cs,
    input               cpu_rnw,
    input               cpu_cen,
    input      [ 7:0]   cpu_addr,
    input      [ 7:0]   cpu_dout,
    output     [ 7:0]   pal_dout,
    // GFX colour requests
    input      [ 6:0]   gfx1_col,
    input      [ 6:0]   gfx2_col,
    // Colours
    output     [ 4:0]   red,
    output     [ 4:0]   green,
    output     [ 4:0]   blue
);

wire        pal_we = cpu_cen & ~cpu_rnw & pal_cs;
wire [ 7:0] col_data;

assign LVBL_dly = LVBL;
assign LHBL_dly = LHBL;

jtframe_dual_ram #(.aw(8)) u_ram(
    .clk0   ( clk24     ),
    .clk1   ( clk       ),
    // Port 0
    .data0  ( cpu_dout  ),
    .addr0  ( cpu_addr  ),
    .we0    ( pal_we    ),
    .q0     ( pal_dout  ),
    // Port 1
    .data1  (           ),
    .addr1  (           ),
    .we1    ( 1'b0      ),
    .q1     ( col_data  )
);

endmodule