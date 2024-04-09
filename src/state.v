`define default_netname none

module chacha_state (
  input wire clk,
  input wire rst_n,

  input wire wr_qr,
  input wire round_sel,
  input wire [1:0] qr_sel,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out,

  input wire wr_all,
  input wire [31:0] s0_in,
  input wire [31:0] s1_in,
  input wire [31:0] s2_in,
  input wire [31:0] s3_in,
  input wire [31:0] s4_in,
  input wire [31:0] s5_in,
  input wire [31:0] s6_in,
  input wire [31:0] s7_in,
  input wire [31:0] s8_in,
  input wire [31:0] s9_in,
  input wire [31:0] s10_in,
  input wire [31:0] s11_in,
  input wire [31:0] s12_in,
  input wire [31:0] s13_in,
  input wire [31:0] s14_in,
  input wire [31:0] s15_in,

  input wire [5:0] addr_in,
  output wire [7:0] data_out
);
  reg [31:0] s_out[15:0];

  wire [3:0] addr_word = addr_in[5:2];
  wire addr_half = addr_in[1];
  wire addr_byte = addr_in[0];

  wire [31:0] current_word = s_out[addr_word];
  assign data_out = addr_half
    ? (addr_byte ? current_word[31:24] : current_word[23:16])
    : (addr_byte ? current_word[15:8] : current_word[7:0]);

  assign a_out = qr_sel[1]
    ? (qr_sel[0] ? s_out[3] : s_out[2])
    : (qr_sel[0] ? s_out[1] : s_out[0]);

  assign b_out = round_sel
    ? (qr_sel[1]
        ? (qr_sel[0] ? s_out[4] : s_out[7])
        : (qr_sel[0] ? s_out[6] : s_out[5])
      )
    : (qr_sel[1]
        ? (qr_sel[0] ? s_out[7] : s_out[6])
        : (qr_sel[0] ? s_out[5] : s_out[4])
      );

  assign c_out = round_sel
    ? (qr_sel[1]
        ? (qr_sel[0] ? s_out[9] : s_out[8])
        : (qr_sel[0] ? s_out[11] : s_out[10])
      )
    : (qr_sel[1]
        ? (qr_sel[0] ? s_out[11] : s_out[10])
        : (qr_sel[0] ? s_out[9] : s_out[8])
      );

  assign d_out = round_sel
    ? (qr_sel[1]
        ? (qr_sel[0] ? s_out[14] : s_out[13])
        : (qr_sel[0] ? s_out[12] : s_out[15])
      )
    : (qr_sel[1]
        ? (qr_sel[0] ? s_out[15] : s_out[14])
        : (qr_sel[0] ? s_out[13] : s_out[12])
      );

  always @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 16; i++) begin
        s_out[i] <= 32'b0;
      end
    end else if (wr_all) begin
      s_out[0] <= s0_in;
      s_out[1] <= s1_in;
      s_out[2] <= s2_in;
      s_out[3] <= s3_in;
      s_out[4] <= s4_in;
      s_out[5] <= s5_in;
      s_out[6] <= s6_in;
      s_out[7] <= s7_in;
      s_out[8] <= s8_in;
      s_out[9] <= s9_in;
      s_out[10] <= s10_in;
      s_out[11] <= s11_in;
      s_out[12] <= s12_in;
      s_out[13] <= s13_in;
      s_out[14] <= s14_in;
      s_out[15] <= s15_in;
    end else if (wr_qr) begin
      if (!qr_sel[1]) begin
        if (!qr_sel[0]) begin
          s_out[0] <= a_in;
          if (!round_sel) begin
            s_out[4] <= b_in;
            s_out[8] <= c_in;
            s_out[12] <= d_in;
          end else begin
            s_out[5] <= b_in;
            s_out[10] <= c_in;
            s_out[15] <= d_in;
          end
        end else begin
          s_out[1] <= a_in;
          if (!round_sel) begin
            s_out[5] <= b_in;
            s_out[9] <= c_in;
            s_out[13] <= d_in;
          end else begin
            s_out[6] <= b_in;
            s_out[11] <= c_in;
            s_out[12] <= d_in;
          end
        end
      end else begin
        if (!qr_sel[0]) begin
          s_out[2] <= a_in;
          if (!round_sel) begin
            s_out[6] <= b_in;
            s_out[10] <= c_in;
            s_out[14] <= d_in;
          end else begin
            s_out[7] <= b_in;
            s_out[8] <= c_in;
            s_out[13] <= d_in;
          end
        end else begin
          s_out[3] <= a_in;
          if (!round_sel) begin
            s_out[7] <= b_in;
            s_out[11] <= c_in;
            s_out[15] <= d_in;
          end else begin
            s_out[4] <= b_in;
            s_out[9] <= c_in;
            s_out[14] <= d_in;
          end
        end
      end
    end
  end

endmodule
