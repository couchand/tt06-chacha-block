`define default_netname none

module chacha_state (
  input wire clk,
  input wire rst_n,

  input wire wr_qr,
  input wire round_sel,

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

  wire [31:0] w_a, w_a_txfr;
  wire [31:0] w_b, w_b_txfr;
  wire [31:0] w_c, w_c_txfr;
  wire [31:0] w_d, w_d_txfr;
  wire [31:0] x_a, x_a_txfr;
  wire [31:0] x_b, x_b_txfr;
  wire [31:0] x_c, x_c_txfr;
  wire [31:0] x_d, x_d_txfr;
  wire [31:0] y_a, y_a_txfr;
  wire [31:0] y_b, y_b_txfr;
  wire [31:0] y_c, y_c_txfr;
  wire [31:0] y_d, y_d_txfr;
  wire [31:0] z_a, z_a_txfr;
  wire [31:0] z_b, z_b_txfr;
  wire [31:0] z_c, z_c_txfr;
  wire [31:0] z_d, z_d_txfr;

  chacha_qr qr_w0 (
    .sel(1'b0),
    .a_in(s[0]),
    .b_in(round_sel ? s[5] : s[4]),
    .c_in(round_sel ? s[10]: s[8]),
    .d_in(round_sel ? s[15] : s[12]),
    .a_out(w_a_txfr),
    .b_out(w_b_txfr),
    .c_out(w_c_txfr),
    .d_out(w_d_txfr)
  );

  chacha_qr qr_w1 (
    .sel(1'b1),
    .a_in(w_a_txfr),
    .b_in(w_b_txfr),
    .c_in(w_c_txfr),
    .d_in(w_d_txfr),
    .a_out(w_a),
    .b_out(w_b),
    .c_out(w_c),
    .d_out(w_d)
  );

  chacha_qr qr_x0 (
    .sel(1'b0),
    .a_in(s[1]),
    .b_in(round_sel ? s[6] : s[5]),
    .c_in(round_sel ? s[11]: s[9]),
    .d_in(round_sel ? s[12] : s[13]),
    .a_out(x_a_txfr),
    .b_out(x_b_txfr),
    .c_out(x_c_txfr),
    .d_out(x_d_txfr)
  );

  chacha_qr qr_x1 (
    .sel(1'b1),
    .a_in(x_a_txfr),
    .b_in(x_b_txfr),
    .c_in(x_c_txfr),
    .d_in(x_d_txfr),
    .a_out(x_a),
    .b_out(x_b),
    .c_out(x_c),
    .d_out(x_d)
  );

  chacha_qr qr_y0 (
    .sel(1'b0),
    .a_in(s[2]),
    .b_in(round_sel ? s[7] : s[6]),
    .c_in(round_sel ? s[8]: s[10]),
    .d_in(round_sel ? s[13] : s[14]),
    .a_out(y_a_txfr),
    .b_out(y_b_txfr),
    .c_out(y_c_txfr),
    .d_out(y_d_txfr)
  );

  chacha_qr qr_y1 (
    .sel(1'b1),
    .a_in(y_a_txfr),
    .b_in(y_b_txfr),
    .c_in(y_c_txfr),
    .d_in(y_d_txfr),
    .a_out(y_a),
    .b_out(y_b),
    .c_out(y_c),
    .d_out(y_d)
  );

  chacha_qr qr_z0 (
    .sel(1'b0),
    .a_in(s[3]),
    .b_in(round_sel ? s[4] : s[7]),
    .c_in(round_sel ? s[9]: s[11]),
    .d_in(round_sel ? s[14] : s[15]),
    .a_out(z_a_txfr),
    .b_out(z_b_txfr),
    .c_out(z_c_txfr),
    .d_out(z_d_txfr)
  );

  chacha_qr qr_z1 (
    .sel(1'b1),
    .a_in(z_a_txfr),
    .b_in(z_b_txfr),
    .c_in(z_c_txfr),
    .d_in(z_d_txfr),
    .a_out(z_a),
    .b_out(z_b),
    .c_out(z_c),
    .d_out(z_d)
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
      s[0] <= w_a;
      s[1] <= x_a;
      s[2] <= y_a;
      s[3] <= z_a;
      s[4] <= round_sel ? z_b : w_b;
      s[5] <= round_sel ? w_b : x_b;
      s[6] <= round_sel ? x_b : y_b;
      s[7] <= round_sel ? y_b : z_b;
      s[8] <= round_sel ? y_c : w_c;
      s[9] <= round_sel ? z_c : x_c;
      s[10] <= round_sel ? w_c : y_c;
      s[11] <= round_sel ? x_c : z_c;
      s[12] <= round_sel ? x_d : w_d;
      s[13] <= round_sel ? y_d : x_d;
      s[14] <= round_sel ? z_d : y_d;
      s[15] <= round_sel ? w_d : z_d;
    end else if (read & !done) begin
      done <= (addr_in + 6'b1) == 6'b0;
    end
  end

endmodule
