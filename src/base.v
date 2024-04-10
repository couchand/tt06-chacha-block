`define default_netname none

module chacha_base (
  input wire clk,
  input wire rst_n,

  input wire wr,
  input wire [5:0] addr_in,
  input wire [7:0] data_in,

  input wire [3:0] word_sel,
  output wire [31:0] data_out
);
  reg [31:0] s[15:0];

  assign data_out = s[word_sel];

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
