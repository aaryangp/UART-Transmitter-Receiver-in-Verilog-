 module uart_receiver (
    input  wire clk,
    input  wire rst,
    input  wire rx,
    input  wire rdy_clr,
    input  wire clk_en,        // 16x baud enable
    output reg  rdy,
    output reg [7:0] data_out
  );

  // -------------------------
  // State encoding
  // -------------------------
  localparam START_STATE = 2'b00;
  localparam DATA_STATE  = 2'b01;
  localparam STOP_STATE  = 2'b10;

  reg [1:0] ps, ns;

  // -------------------------
  // Internal registers
  // -------------------------
  reg [3:0] sample;          // 0–15 (16x oversampling)
  reg [3:0] index;           // bit index 0–7
  reg [7:0] temp_register;

  // =========================================================
  // 1️⃣ PRESENT STATE + REGISTER UPDATE (Sequential)
  // =========================================================
  always @(posedge clk)
  begin
    if (rst)
    begin
      ps            <= START_STATE;
      sample        <= 4'd0;
      index         <= 3'd0;
      temp_register <= 8'd0;
      data_out      <= 8'd0;
      rdy           <= 1'b0;
    end
    else
    begin
      ps <= ns;

      if (rdy_clr)
        rdy <= 1'b0;

      if (clk_en)
      begin
        case (ps)

          // -------------------------
          // START STATE
          // -------------------------
          START_STATE:
          begin
            if (rx == 1'b0)
              sample <= sample + 1'b1;
            else
              sample <= 4'd0;

            if (sample == 4'd15)
            begin
              sample        <= 4'd0;
              index         <= 3'd0;
              temp_register <= 8'd0;
            end
          end

          // -------------------------
          // DATA STATE
          // -------------------------
          DATA_STATE:
          begin
            if (sample == 4'd15)
              sample <= 4'd0;
            else
              sample <= sample + 1'b1;

            if (sample == 4'd8)
            begin
              temp_register[index] <= rx;
              index <= index + 1'b1;
            end
          end

          // -------------------------
          // STOP STATE
          // -------------------------
          STOP_STATE:
          begin
            sample <= sample + 1'b1;

            if (sample == 4'd15)
            begin
              data_out <= temp_register;
              rdy      <= 1'b1;
              sample   <= 4'd0;
            end
          end

        endcase
      end
    end
  end

  // =========================================================
  // 2️⃣ NEXT STATE LOGIC (Combinational)
  // =========================================================
  always @(*)
  begin
    ns = ps;   // default stay

    case (ps)

      START_STATE:
      begin
        if (sample == 4'd15)
          ns = DATA_STATE;
      end

      DATA_STATE:
      begin
        if (index == 4'd8 && sample == 4'd15)
          ns = STOP_STATE;
      end

      STOP_STATE:
      begin
        if (sample == 4'd15)
          ns = START_STATE;
      end

      default:
        ns = START_STATE;
    endcase
  end

endmodule 



