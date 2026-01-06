module uart_transmitter(
    input        wr_enb,
    input        tx_enb,
    input        clk,
    input        rst,
    input  [7:0] data_in,
    output       busy,
    output reg   tx
);

  parameter [1:0] idle  = 2'b00;
  parameter [1:0] start = 2'b01;
  parameter [1:0] data  = 2'b10;
  parameter [1:0] stop  = 2'b11;

  reg [7:0] data_buffer;
  reg [1:0] ps, ns;
  reg [2:0] index;

  // -------------------------
  // State register
  // -------------------------
  always @(posedge clk) begin
    if (rst)
      ps <= idle;
    else
      ps <= ns;
  end

  // -------------------------
  // Datapath / outputs
  // -------------------------
  always @(posedge clk) begin
    if (rst) begin
      tx          <= 1'b1;     // idle line high
      index       <= 3'd0;
      data_buffer <= 8'd0;
    end
    else begin
      // LOAD DATA when starting transmission
      if (ps == idle && wr_enb) begin
        data_buffer <= data_in;
        index       <= 3'd0;
      end

      // Advance only on baud enable
      if (tx_enb) begin
        case (ps)
          idle: begin
            tx <= 1'b1;
          end

          start: begin
            tx <= 1'b0;        // start bit
          end

          data: begin
            tx <= data_buffer[index];
            index <= index + 1'b1;
          end

          stop: begin
            tx <= 1'b1;        // stop bit
          end
        endcase
      end
    end
  end

  // -------------------------
  // Next-state logic
  // -------------------------
  always @(*) begin
    ns = ps;
    case (ps)
      idle:
        if (wr_enb)
          ns = start;

      start:
        if (tx_enb)
          ns = data;

      data:
        if (tx_enb && index == 3'd7)
          ns = stop;

      stop:
        if (tx_enb)
          ns = idle;
    endcase
  end

  assign busy = (ps != idle);

endmodule
