`define default_netname none

module chacha_base (
  input wire clk,
  input wire rst_n,

  input wire wr,
  input wire [5:0] addr_in,
  input wire [7:0] data_in,

  input wire [1:0] qr_sel,
  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
  reg [31:0] s[15:0];

  assign a_out = qr_sel[1]
    ? (qr_sel[0] ? s[3] : s[2])
    : (qr_sel[0] ? s[1] : s[0]);

  assign b_out = qr_sel[1]
    ? (qr_sel[0] ? s[7] : s[6])
    : (qr_sel[0] ? s[5] : s[4]);

  assign c_out = qr_sel[1]
    ? (qr_sel[0] ? s[11] : s[10])
    : (qr_sel[0] ? s[9] : s[8]);

  assign d_out = qr_sel[1]
    ? (qr_sel[0] ? s[15] : s[14])
    : (qr_sel[0] ? s[13] : s[12]);

  wire [3:0] addr_word = addr_in[5:2];
  wire addr_half = addr_in[1];
  wire addr_byte = addr_in[0];

  always @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 16; i++) begin
        s[i] <= 32'b0;
      end
    end else if (wr) begin
      if (addr_half) begin
        if (addr_byte) begin
          s[addr_word][31:24] <= data_in;
        end else begin
          s[addr_word][23:16] <= data_in;
        end
      end else begin
        if (addr_byte) begin
          s[addr_word][15:8] <= data_in;
        end else begin
          s[addr_word][7:0] <= data_in;
        end
      end
    end
  end

endmodule
