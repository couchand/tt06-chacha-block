`define default_netname none

module chacha_qr (
    input  wire sel,
    input  wire [31:0] a_in,
    input  wire [31:0] b_in,
    input  wire [31:0] c_in,
    input  wire [31:0] d_in,
    output wire [31:0] a_out,
    output wire [31:0] b_out,
    output wire [31:0] c_out,
    output wire [31:0] d_out
);

  wire [31:0] a_plus_b = a_in + b_in;
  wire [31:0] d_xor_apb = d_in ^ a_plus_b;

  wire [31:0] dxa_rotl_16 = (d_xor_apb << 16) | (d_xor_apb >> 16);
  wire [31:0] dxa_rotl_8 = (d_xor_apb << 8) | (d_xor_apb >> 24);
  wire [31:0] dxa_rotl = sel ? dxa_rotl_8 : dxa_rotl_16;

  wire [31:0] c_plus_d = c_in + dxa_rotl;
  wire [31:0] b_xor_cpd = b_in ^ c_plus_d;
  wire [31:0] bxc_rotl_12 = (b_xor_cpd << 12) | (b_xor_cpd >> 20);
  wire [31:0] bxc_rotl_7 = (b_xor_cpd << 7) | (b_xor_cpd >> 25);
  wire [31:0] bxc_rotl = sel ? bxc_rotl_7 : bxc_rotl_12;

  assign a_out = a_plus_b;
  assign b_out = bxc_rotl;
  assign c_out = c_plus_d;
  assign d_out = dxa_rotl;

endmodule
