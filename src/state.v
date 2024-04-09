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

  output wire [31:0] a1,
  output wire [31:0] a2,
  output wire [31:0] a3,

  input wire wr_addr,
  input wire [5:0] addr_in,
  input wire [7:0] data_in,
  output wire [7:0] data_out
);
  reg [31:0] s_out[15:0];

  assign a1 = s_out[1];
  assign a2 = s_out[2];
  assign a3 = s_out[3];

  wire [31:0] current_word = s_out[addr_in[5:2]];
  assign data_out = addr_in[1]
    ? (addr_in[0] ? current_word[31:24] : current_word[23:16])
    : (addr_in[0] ? current_word[15:8] : current_word[7:0]);

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
    end else if (wr_addr) begin
      if (addr_in[1]) begin
        if (addr_in[0]) begin
          s_out[addr_in[5:2]][31:24] <= data_in;
        end else begin
          s_out[addr_in[5:2]][23:16] <= data_in;
        end
      end else begin
        if (addr_in[0]) begin
          s_out[addr_in[5:2]][15:8] <= data_in;
        end else begin
          s_out[addr_in[5:2]][7:0] <= data_in;
        end
      end
    end
  end

endmodule
