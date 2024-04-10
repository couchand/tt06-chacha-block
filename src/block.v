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
  localparam STATE_ROUND = 5;

  reg [2:0] state;

  assign ready = !write & (state == STATE_READY);
  wire copying = !write & (state == STATE_COPY);
  wire calculating = !write & (state == STATE_CALC);
  wire summing = !write & (state == STATE_SUM);
  wire rounding = !write & (state == STATE_ROUND);

  reg [5:0] addr_counter;

  reg [6:0] counter;

  wire [4:0] round = counter[6:2];
  wire round_sel = round[0];

  wire [1:0] sr_sel = counter[1:0];

  reg [3:0] word_sel;
  wire [31:0] word_txfr;

  wire done;

  chacha_base block_base (
    .clk(clk),
    .rst_n(rst_n),
    .wr(write),
    .addr_in(addr_counter),
    .data_in(data_in),
    .word_sel(word_sel),
    .data_out(word_txfr)
  );

  chacha_state block_state (
    .clk(clk),
    .rst_n(rst_n),
    .wr_qr(calculating),
    .round_sel(round_sel),
    .sr_sel(sr_sel),
    .wr_in(copying),
    .wr_add(summing),
    .word_sel(word_sel),
    .data_in(word_txfr),
    .read(read),
    .addr_in(addr_counter),
    .done(done),
    .data_out(data_out)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      state <= STATE_READY;
      addr_counter <= 0;
      counter <= 0;
      word_sel <= 0;
    end else if (write) begin
      state <= STATE_COPY;
      counter <= 0;
      word_sel <= 0;
      addr_counter <= addr_counter + 1;
    end else if (copying) begin
      word_sel <= word_sel + 1;
      if (word_sel + 4'b1 == 4'b0) begin
        state <= STATE_CALC;
      end
    end else if (rounding) begin
      addr_counter <= 0;
      if (round == 20) begin
        state <= STATE_SUM;
      end else begin
        state <= STATE_CALC;
      end
    end else if (calculating) begin
      addr_counter <= 0;
      counter <= counter + 1;
      if (((counter + 7'b1) & 7'b11) == 0) begin
        state <= STATE_ROUND;
      end
    end else if (summing) begin
      word_sel <= word_sel + 1;
      if (word_sel + 4'b1 == 4'b0) begin
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
