`define default_netname none

module block (
  input wire clk,
  input wire rst_n,
  input wire [7:0] data_in,
  input wire [7:0] data_out,
  input wire [5:0] addr_in,
  input wire write,
  output reg ready
);

  reg [7:0] counter;

  wire [4:0] round = counter[7:3];

  wire round_sel = round[0];
  wire [1:0] quarter_round_sel = counter[2:1];
  wire eighth_round_sel = counter[0];

  wire [31:0] a_rd, b_rd, c_rd, d_rd;
  wire [31:0] a_wr, b_wr, c_wr, d_wr;

  wire calculating = !ready & !write;

  wire [31:0] a1, a2, a3;

  chacha_state block_state (
    .clk(clk),
    .rst_n(rst_n),
    .wr_qr(calculating),
    .round_sel(round_sel),
    .qr_sel(quarter_round_sel),
    .a_in(a_wr),
    .b_in(b_wr),
    .c_in(c_wr),
    .d_in(d_wr),
    .a_out(a_rd),
    .b_out(b_rd),
    .c_out(c_rd),
    .d_out(d_rd),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .wr_addr(write),
    .addr_in(addr_in),
    .data_in(data_in),
    .data_out(data_out)
  );

  chacha_qr block_qr (
    .sel(eighth_round_sel),
    .a_in(a_rd),
    .b_in(b_rd),
    .c_in(c_rd),
    .d_in(d_rd),
    .a_out(a_wr),
    .b_out(b_wr),
    .c_out(c_wr),
    .d_out(d_wr)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      ready <= 1;
      counter <= 0;
    end else if (write) begin
      ready <= 0;
      counter <= 0;
    end else if (!ready) begin
      counter <= counter + 1;
      ready <= (counter + 1) == (20 << 3);
    end
  end

endmodule
