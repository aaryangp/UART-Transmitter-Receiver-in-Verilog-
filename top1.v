`include "transmitter.v"
`include "reciever.v"
`include "baudrategen.v"

module top1(

input clk , rst ,wr_en , rdy_clr,
input [7:0] data_in ,
output rdy,busy, 
output [7:0] data_out 
);

wire tx_temp;
wire rx_clk_en ;
wire tx_clk_en ;

uart_transmitter tx(
        wr_en ,
        tx_clk_en  ,
        clk , 
         rst ,
         data_in ,
         busy ,
        tx_temp
);

uart_receiver rx( 
      clk,
      rst,
      tx_temp,
      rdy_clr,
      rx_clk_en,      
      rdy,
     data_out
);

baudrategenerator bg(
  .clk(clk),
  .rst(rst),
  .tx_enb(tx_clk_en),
  .rx_enb(rx_clk_en)
);


endmodule