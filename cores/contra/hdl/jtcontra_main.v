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
    Date: 2-12-2019 */

// Clocks are derived from H counter on the original PCB
// Yet, that doesn't seem to be important and it only
// matters the frequency of the signals:
// E,Q: 3 MHz
// Q is 1/4th of wave advanced

module jtcontra_main(
    input               clk,        // 24 MHz
    input               rst,
    input               cen12,
    output              cpu_cen,
    // communication with sound CPU
    output              snd_irq,
    output      [ 7:0]  snd_latch,
    // ROM
    output      [17:0]  rom_addr,
    output              rom_cs,
    input       [ 7:0]  rom_data,
    input               rom_ok,
    // cabinet I/O
    input       [ 1:0]  start_button,
    input       [ 1:0]  coin_input,
    input       [ 5:0]  joystick1,
    input       [ 5:0]  joystick2,
    input               service,
    // GFX
    output      [15:0]  cpu_addr,
    output              cpu_rnw,
    output      [ 7:0]  cpu_dout,
    input               gfx_irqn,
    input               gfx1_cs,
    input               gfx2_cs,
    output              pal_cs,

    output     [7:0]    video_bank,
    output              prio_latch,

    input      [7:0]    gfx1_dout,
    input      [7:0]    gfx2_dout,
    input      [7:0]    pal_dout,
    // DIP switches
    input               dip_pause,
    input      [7:0]    dipsw_a,
    input      [7:0]    dipsw_b,
    input      [3:0]    dipsw_c
);

parameter GAME=0;

wire [ 7:0] ram_dout, cpu_din;
wire [15:0] A;
wire        RnW, irq_n, irq_ack;
wire        irq_trigger;
wire        ram_cs;

assign irq_trigger = ~gfx_irqn & dip_pause;
assign cpu_addr    = A;
assign cpu_rnw     = RnW;

generate
    case( GAME )
        0: begin ////////////// CONTRA
            jtcontra_main_decoder u_decoder(
                .clk            ( clk           ),        // 24 MHz
                .rst            ( rst           ),
                //.cen12          ( cen12         ),
                .cpu_cen        ( cpu_cen       ),
                .A              ( A             ),
                .RnW            ( RnW           ),
                .gfx1_cs        ( gfx1_cs       ),
                .gfx2_cs        ( gfx2_cs       ),
                .pal_cs         ( pal_cs        ),
                // communication with main CPU
                .snd_irq        ( snd_irq       ),
                .snd_latch      ( snd_latch     ),
                // ROM
                .rom_addr       ( rom_addr[16:0]),
                .rom_cs         ( rom_cs        ),
                .rom_data       ( rom_data      ),
                .rom_ok         ( rom_ok        ),
                // cabinet I/O
                .start_button   ( start_button  ),
                .coin_input     ( coin_input    ),
                .joystick1      ( joystick1     ),
                .joystick2      ( joystick2     ),
                .service        ( service       ),
                // Data bus
                .cpu_dout       ( cpu_dout      ),
                .pal_dout       ( pal_dout      ),
                .gfx1_dout      ( gfx1_dout     ),
                .gfx2_dout      ( gfx2_dout     ),
                .ram_cs         ( ram_cs        ),
                .cpu_din        ( cpu_din       ),
                .ram_dout       ( ram_dout      ),
                // DIP switches
                .dipsw_a        ( dipsw_a       ),
                .dipsw_b        ( dipsw_b       ),
                .dipsw_c        ( dipsw_c       )
            );
            // Unused signals:
            assign rom_addr[17] = 0;
            assign prio_latch   = 0;
            assign video_bank   = 8'd0;
        end
        1: begin ////////////// Combat School
            jtcomsc_main_decoder u_decoder(
                .clk            ( clk           ),        // 24 MHz
                .rst            ( rst           ),
                //.cen12          ( cen12         ),
                .cpu_cen        ( cpu_cen       ),
                .A              ( A             ),
                .RnW            ( RnW           ),
                .gfx1_cs        ( gfx1_cs       ),
                .gfx2_cs        ( gfx2_cs       ),
                .pal_cs         ( pal_cs        ),
                .prio_latch     ( prio_latch    ),
                .video_bank     ( video_bank    ),
                // communication with sound CPU
                .snd_irq        ( snd_irq       ),
                .snd_latch      ( snd_latch     ),
                // ROM
                .rom_addr       ( rom_addr      ),
                .rom_cs         ( rom_cs        ),
                .rom_data       ( rom_data      ),
                .rom_ok         ( rom_ok        ),
                // cabinet I/O
                .start_button   ( start_button  ),
                .coin_input     ( coin_input    ),
                .joystick1      ( joystick1     ),
                .joystick2      ( joystick2     ),
                .service        ( service       ),
                // Data bus
                .cpu_dout       ( cpu_dout      ),
                .pal_dout       ( pal_dout      ),
                .gfx1_dout      ( gfx1_dout     ),
                .gfx2_dout      ( gfx2_dout     ),
                .ram_cs         ( ram_cs        ),
                .cpu_din        ( cpu_din       ),
                .ram_dout       ( ram_dout      ),
                // DIP switches
                .dipsw_a        ( dipsw_a       ),
                .dipsw_b        ( dipsw_b       ),
                .dipsw_c        ( dipsw_c       )
            );
        end
    endcase    
endgenerate

jtframe_ff u_ff(
    .clk      ( clk         ),
    .rst      ( rst         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( irq_n       ),
    .set      (             ),    // active high
    .clr      ( irq_ack     ),    // active high
    .sigedge  ( irq_trigger )     // signal whose edge will trigger the FF
);

jtframe_sys6809 #(.RAM_AW(12)) u_cpu(
    .rstn       ( ~rst      ), 
    .clk        ( clk       ),
    .cen        ( cen12     ),   // This is normally the input clock to the CPU
    .cpu_cen    ( cpu_cen   ),   // 1/4th of cen -> 3MHz

    // Interrupts
    .nIRQ       ( irq_n     ),
    .nFIRQ      ( 1'b1      ),
    .nNMI       ( 1'b1      ),
    .irq_ack    ( irq_ack   ),
    // Bus sharing
    .bus_busy   ( 1'b0      ),
    .waitn      (           ),
    // memory interface
    .A          ( A         ),
    .RnW        ( RnW       ),
    .ram_cs     ( ram_cs    ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),
    // Bus multiplexer is external
    .ram_dout   ( ram_dout  ),
    .cpu_dout   ( cpu_dout  ),
    .cpu_din    ( cpu_din   )
);

`ifdef SIMULATION
always @(negedge snd_irq) $display("INFO: sound latch %X", snd_latch );
`endif

endmodule
