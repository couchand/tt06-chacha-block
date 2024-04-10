`define default_netname none

module chacha_qr (
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
  wire [31:0] dxa_rotl_16;
  assign dxa_rotl_16[15:0] = d_xor_apb[31:16];
  assign dxa_rotl_16[31:16] = d_xor_apb[15:0];

  wire [31:0] c_plus_d = c_in + dxa_rotl_16;
  wire [31:0] b_xor_cpd = b_in ^ c_plus_d;
  wire [31:0] bxc_rotl_12;
  assign bxc_rotl_12[11:0] = b_xor_cpd[31:20];
  assign bxc_rotl_12[31:12] = b_xor_cpd[19:0];

  wire [31:0] apb_plus_br12 = a_plus_b + bxc_rotl_12;
  wire [31:0] dr16_xor_apb = dxa_rotl_16 ^ apb_plus_br12;
  wire [31:0] dxa_rotl_8;
  assign dxa_rotl_8[7:0] = dr16_xor_apb[31:24];
  assign dxa_rotl_8[31:8] = dr16_xor_apb[23:0];

  wire [31:0] cpd_plus_dr8 = c_plus_d + dxa_rotl_8;
  wire [31:0] br12_xor_cpd = bxc_rotl_12 ^ cpd_plus_dr8;
  wire [31:0] bxc_rotl_7;
  assign bxc_rotl_7[6:0] = br12_xor_cpd[31:25];
  assign bxc_rotl_7[31:7] = br12_xor_cpd[24:0];

  assign a_out = apb_plus_br12;
  assign b_out = bxc_rotl_7;
  assign c_out = cpd_plus_dr8;
  assign d_out = dxa_rotl_8;

endmodule
