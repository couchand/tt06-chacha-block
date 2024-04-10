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

  reg [5:0] addr_counter;

  reg [4:0] round;
  wire round_sel = round[0];

  reg [1:0] quarter_round_sel;

  wire [31:0] a_rd, b_rd, c_rd, d_rd;
  wire [31:0] a_qr, b_qr, c_qr, d_qr;
  wire [31:0] a_base, b_base, c_base, d_base;
  wire [31:0] a_wr = calculating ? a_qr : a_base;
  wire [31:0] b_wr = calculating ? b_qr : b_base;
  wire [31:0] c_wr = calculating ? c_qr : c_base;
  wire [31:0] d_wr = calculating ? d_qr : d_base;

  wire done;

  chacha_base block_base (
    .clk(clk),
    .rst_n(rst_n),
    .wr(write),
    .addr_in(addr_counter),
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
    .wr_qr(calculating),
    .round_sel(round_sel),
    .wr_in(copying),
    .wr_add(summing),
    .qr_sel(quarter_round_sel),
    .a_in(a_base),
    .b_in(b_base),
    .c_in(c_base),
    .d_in(d_base),
    .read(read),
    .addr_in(addr_counter),
    .done(done),
    .data_out(data_out)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      state <= STATE_READY;
      addr_counter <= 0;
      round <= 0;
      quarter_round_sel <= 0;
    end else if (write) begin
      state <= STATE_COPY;
      round <= 0;
      quarter_round_sel <= 0;
      addr_counter <= addr_counter + 1;
    end else if (copying) begin
      quarter_round_sel <= quarter_round_sel + 1;
      if (quarter_round_sel + 2'b1 == 2'b0) begin
        state <= STATE_CALC;
      end
    end else if (calculating) begin
      addr_counter <= 0;
      round <= round + 1;
      if (round + 5'b1 == 5'd20) begin
        round <= 0;
        state <= STATE_SUM;
      end
    end else if (summing) begin
      quarter_round_sel <= quarter_round_sel + 1;
      if (quarter_round_sel + 2'b1 == 2'b0) begin
        state <= STATE_READY;
      end
    end else if (read) begin
      addr_counter <= addr_counter + 1;
    end else if (done) begin
      addr_counter <= 0;
      state <= STATE_INC;
    end
  end

endmodule
