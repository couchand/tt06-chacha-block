`define default_netname none

module block (
  input wire clk,
  input wire rst_n,
  input wire [7:0] data_in,
  output wire [7:0] data_out,
  input wire write,
  input wire read,
  output wire ready
);

  localparam STATE_COPY = 1;
  localparam STATE_CALC = 2;
  localparam STATE_FLUSH = 3;
  localparam STATE_READY = 0;

  reg [1:0] state;

  assign ready = !write & (state == STATE_READY);
  wire copying = !write & (state == STATE_COPY);
  wire calculating = !write & (state == STATE_CALC);
  wire flushing = !write & (state == STATE_FLUSH);

  reg [7:0] counter;

  wire [4:0] round = counter[7:3];

  wire round_sel = round[0];
  wire [1:0] quarter_round_sel = counter[2:1];
  wire eighth_round_sel = counter[0];

  wire [31:0] a_rd, b_rd, c_rd, d_rd;
  wire [31:0] a_wr, b_wr, c_wr, d_wr;

  wire [31:0] s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15;

  chacha_base block_base (
    .clk(clk),
    .rst_n(rst_n),
    .wr(write),
    .data_in(data_in),
    .s0(s0),
    .s1(s1),
    .s2(s2),
    .s3(s3),
    .s4(s4),
    .s5(s5),
    .s6(s6),
    .s7(s7),
    .s8(s8),
    .s9(s9),
    .s10(s10),
    .s11(s11),
    .s12(s12),
    .s13(s13),
    .s14(s14),
    .s15(s15)
  );

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
    .wr_all(copying),
    .wr_add(flushing),
    .s0_in(s0),
    .s1_in(s1),
    .s2_in(s2),
    .s3_in(s3),
    .s4_in(s4),
    .s5_in(s5),
    .s6_in(s6),
    .s7_in(s7),
    .s8_in(s8),
    .s9_in(s9),
    .s10_in(s10),
    .s11_in(s11),
    .s12_in(s12),
    .s13_in(s13),
    .s14_in(s14),
    .s15_in(s15),
    .read(read),
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
      state <= STATE_READY;
      counter <= 0;
    end else if (write) begin
      state <= STATE_COPY;
      counter <= 0;
    end else if (copying) begin
      state <= STATE_CALC;
    end else if (calculating) begin
      counter <= counter + 1;
      if ((counter + 1) == (20 << 3)) begin
        state <= STATE_FLUSH;
      end
    end else if (flushing) begin
      state <= STATE_READY;
    end
  end

endmodule
