`define default_netname none

module chacha_base (
  input wire clk,
  input wire rst_n,

  input wire wr,
  input wire [7:0] data_in,

  output wire [31:0] s0,
  output wire [31:0] s1,
  output wire [31:0] s2,
  output wire [31:0] s3,
  output wire [31:0] s4,
  output wire [31:0] s5,
  output wire [31:0] s6,
  output wire [31:0] s7,
  output wire [31:0] s8,
  output wire [31:0] s9,
  output wire [31:0] s10,
  output wire [31:0] s11,
  output wire [31:0] s12,
  output wire [31:0] s13,
  output wire [31:0] s14,
  output wire [31:0] s15
);
  reg [31:0] s[15:0];

  assign s0 = s[0];
  assign s1 = s[1];
  assign s2 = s[2];
  assign s3 = s[3];
  assign s4 = s[4];
  assign s5 = s[5];
  assign s6 = s[6];
  assign s7 = s[7];
  assign s8 = s[8];
  assign s9 = s[9];
  assign s10 = s[10];
  assign s11 = s[11];
  assign s12 = s[12];
  assign s13 = s[13];
  assign s14 = s[14];
  assign s15 = s[15];

  reg [5:0] addr_counter;

  wire [3:0] addr_word = addr_counter[5:2];
  wire addr_half = addr_counter[1];
  wire addr_byte = addr_counter[0];

  always @(posedge clk) begin
    if (!rst_n) begin
      addr_counter <= 0;
      for (int i = 0; i < 16; i++) begin
        s[i] <= 32'b0;
      end
    end else if (wr) begin
      addr_counter <= addr_counter + 1;
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
