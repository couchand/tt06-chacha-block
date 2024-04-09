/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_couchand_chacha_block (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_out[6:0] = 0;
  assign uio_oe  = 8'b10000000;

  block block_instance (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(ui_in),
    .data_out(uo_out),
    .addr_in(uio_in[5:0]),
    .write(uio_in[6]),
    .ready(uio_out[7])
  );

endmodule
