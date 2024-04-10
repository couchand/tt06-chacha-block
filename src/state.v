`define default_netname none

module chacha_state (
  input wire clk,
  input wire rst_n,

  input wire wr_qr,
  input wire round_sel,
  input wire [1:0] sr_sel,

  input wire wr_in,
  input wire wr_add,
  input wire [3:0] word_sel,
  input wire [31:0] data_in,

  input wire read,
  input wire [5:0] addr_in,
  output reg done,
  output wire [7:0] data_out
);
  reg [31:0] s[15:0];

  wire [3:0] addr_word = addr_in[5:2];
  wire addr_half = addr_in[1];
  wire addr_byte = addr_in[0];

  wire [31:0] current_word = s[addr_word];
  assign data_out = addr_half
    ? (addr_byte ? current_word[31:24] : current_word[23:16])
    : (addr_byte ? current_word[15:8] : current_word[7:0]);

  wire [31:0] w0_a, w1_a;
  wire [31:0] w0_b, w1_b;
  wire [31:0] w0_c, w1_c;
  wire [31:0] w0_d, w1_d;
  wire [31:0] x0_a, x1_a;
  wire [31:0] x0_b, x1_b;
  wire [31:0] x0_c, x1_c;
  wire [31:0] x0_d, x1_d;
  wire [31:0] y0_a, y1_a;
  wire [31:0] y0_b, y1_b;
  wire [31:0] y0_c, y1_c;
  wire [31:0] y0_d, y1_d;
  wire [31:0] z0_a, z1_a;
  wire [31:0] z0_b, z1_b;
  wire [31:0] z0_c, z1_c;
  wire [31:0] z0_d, z1_d;

  chacha_qr qr_w0 (
    .sr_sel(sr_sel),
    .a_in(s[0]),
    .b_in(s[4]),
    .c_in(s[8]),
    .d_in(s[12]),
    .a_out(w0_a),
    .b_out(w0_b),
    .c_out(w0_c),
    .d_out(w0_d)
  );

  chacha_qr qr_w1 (
    .sr_sel(sr_sel),
    .a_in(s[0]),
    .b_in(s[5]),
    .c_in(s[10]),
    .d_in(s[15]),
    .a_out(w1_a),
    .b_out(w1_b),
    .c_out(w1_c),
    .d_out(w1_d)
  );

  chacha_qr qr_x0 (
    .sr_sel(sr_sel),
    .a_in(s[1]),
    .b_in(s[5]),
    .c_in(s[9]),
    .d_in(s[13]),
    .a_out(x0_a),
    .b_out(x0_b),
    .c_out(x0_c),
    .d_out(x0_d)
  );

  chacha_qr qr_x1 (
    .sr_sel(sr_sel),
    .a_in(s[1]),
    .b_in(s[6]),
    .c_in(s[11]),
    .d_in(s[12]),
    .a_out(x1_a),
    .b_out(x1_b),
    .c_out(x1_c),
    .d_out(x1_d)
  );

  chacha_qr qr_y0 (
    .sr_sel(sr_sel),
    .a_in(s[2]),
    .b_in(s[6]),
    .c_in(s[10]),
    .d_in(s[14]),
    .a_out(y0_a),
    .b_out(y0_b),
    .c_out(y0_c),
    .d_out(y0_d)
  );

  chacha_qr qr_y1 (
    .sr_sel(sr_sel),
    .a_in(s[2]),
    .b_in(s[7]),
    .c_in(s[8]),
    .d_in(s[13]),
    .a_out(y1_a),
    .b_out(y1_b),
    .c_out(y1_c),
    .d_out(y1_d)
  );

  chacha_qr qr_z0 (
    .sr_sel(sr_sel),
    .a_in(s[3]),
    .b_in(s[7]),
    .c_in(s[11]),
    .d_in(s[15]),
    .a_out(z0_a),
    .b_out(z0_b),
    .c_out(z0_c),
    .d_out(z0_d)
  );

  chacha_qr qr_z1 (
    .sr_sel(sr_sel),
    .a_in(s[3]),
    .b_in(s[4]),
    .c_in(s[9]),
    .d_in(s[14]),
    .a_out(z1_a),
    .b_out(z1_b),
    .c_out(z1_c),
    .d_out(z1_d)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      done <= 0;
      for (int i = 0; i < 16; i++) begin
        s[i] <= 32'b0;
      end
    end else if (wr_in) begin
      s[word_sel] <= data_in;
    end else if (wr_add) begin
      s[word_sel] <= data_in + s[word_sel];
    end else if (wr_qr) begin
      s[0] <= round_sel ? w1_a : w0_a;
      s[1] <= round_sel ? x1_a : x0_a;
      s[2] <= round_sel ? y1_a : y0_a;
      s[3] <= round_sel ? z1_a : z0_a;
      s[4] <= round_sel ? z1_b : w0_b;
      s[5] <= round_sel ? w1_b : x0_b;
      s[6] <= round_sel ? x1_b : y0_b;
      s[7] <= round_sel ? y1_b : z0_b;
      s[8] <= round_sel ? y1_c : w0_c;
      s[9] <= round_sel ? z1_c : x0_c;
      s[10] <= round_sel ? w1_c : y0_c;
      s[11] <= round_sel ? x1_c : z0_c;
      s[12] <= round_sel ? x1_d : w0_d;
      s[13] <= round_sel ? y1_d : x0_d;
      s[14] <= round_sel ? z1_d : y0_d;
      s[15] <= round_sel ? w1_d : z0_d;
    end else if (read & !done) begin
      done <= (addr_in + 6'b1) == 6'b0;
    end
  end

endmodule
