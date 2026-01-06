`include "top1.v"
`timescale 1ns/1ps

module tb_top1;

  // -------------------------
  // Testbench signals
  // -------------------------
  reg clk;
  reg rst;
  reg wr_en;
  reg rdy_clr;
  reg [7:0] data_in;

  wire rdy;
  wire busy;
  wire [7:0] data_out;

  // -------------------------
  // DUT
  // -------------------------
  top1 dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rdy_clr(rdy_clr),
    .data_in(data_in),
    .rdy(rdy),
    .busy(busy),
    .data_out(data_out)
  );

  initial begin
    {clk,rst,data_in,rdy_clr} = 0;

  end
  // -------------------------
  // Clock (50 MHz)
  // -------------------------
  always #10 clk = ~clk;

  // -------------------------
  // Dump waveforms
  // -------------------------
  initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, tb_top1);
  end

  // -------------------------
  // TASK: send_byte
  // -------------------------
  task send_byte(input [7:0] din);
  begin
    @(negedge clk);
    data_in = din;
    wr_en   = 1'b1;
    @(negedge clk);
    wr_en   = 1'b0;
  end
  endtask

  task clear_ready;
  begin
    @(negedge clk);
    rdy_clr = 1'b1;
    @(negedge clk);
    rdy_clr = 1'b0;
  end
  endtask


  initial begin
    
   @(negedge clk)
   rst = 1'b1 ;

   @(negedge clk)
   rst = 1'b0 ;

    send_byte(8'h41);     // 'A'
    wait(!busy);          // TX done
    wait(rdy);            // RX done
    $display("Received data is %h", data_out);
    clear_ready;

  
    send_byte(8'h55);
    wait(!busy);
    wait(rdy);
    $display("Received data is %h", data_out);
    clear_ready;

    // Finish
    #400;
    $finish;
  end

endmodule
