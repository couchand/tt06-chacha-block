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
  localparam STATE_SUM = 3;
  localparam STATE_READY = 0;
  localparam STATE_INC = 4;

  reg [2:0] state;

  assign ready = !write & (state == STATE_READY);
  wire copying = !write & (state == STATE_COPY);
  wire calculating = !write & (state == STATE_CALC);
  wire summing = !write & (state == STATE_SUM);

  reg [7:0] counter;

  wire [4:0] round = counter[7:3];

  wire round_sel = round[0];
  wire [1:0] quarter_round_sel = counter[2:1];
  wire eighth_round_sel = counter[0];

  wire [31:0] a_rd, b_rd, c_rd, d_rd;
  wire [31:0] a_qr, b_qr, c_qr, d_qr;
  wire [31:0] a_base, b_base, c_base, d_base;
  wire [31:0] a_wr = calculating ? a_qr : a_base;
  wire [31:0] b_wr = calculating ? b_qr : b_base;
  wire [31:0] c_wr = calculating ? c_qr : c_base;
  wire [31:0] d_wr = calculating ? d_qr : d_base;

  wire state_wr_qr = calculating | copying;
  wire done;

  chacha_base block_base (
    .clk(clk),
    .rst_n(rst_n),
    .wr(write),
    .data_in(data_in),
    .qr_sel(quarter_round_sel),
    .a_out(a_base),
    .b_out(b_base),
    .c_out(c_base),
    .d_out(d_base)
  );

  chacha_state block_state (
    .clk(clk),
    .rst_n(rst_n),
    .wr_qr(state_wr_qr),
    .wr_add(summing),
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
    .read(read),
    .done(done),
    .data_out(data_out)
  );

  chacha_qr block_qr (
    .sel(eighth_round_sel),
    .a_in(a_rd),
    .b_in(b_rd),
    .c_in(c_rd),
    .d_in(d_rd),
    .a_out(a_qr),
    .b_out(b_qr),
    .c_out(c_qr),
    .d_out(d_qr)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      state <= STATE_READY;
      counter <= 0;
    end else if (write) begin
      state <= STATE_COPY;
      counter <= 0;
    end else if (copying) begin
      if (counter + 2 == (1 << 3)) begin
        counter <= 0;
        state <= STATE_CALC;
      end else begin
        counter <= counter + 2;
      end
    end else if (calculating) begin
      counter <= counter + 1;
      if ((counter + 1) == (20 << 3)) begin
        counter <= 0;
        state <= STATE_SUM;
      end
    end else if (summing) begin
      if (counter + 2 == (1 << 3)) begin
        counter <= 0;
        state <= STATE_READY;
      end else begin
        counter <= counter + 2;
      end
    end else if (done) begin
      state <= STATE_INC;
    end
  end

endmodule
