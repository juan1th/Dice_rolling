//  --------------------------------------------------------------------------
//                    Copyright Message
//  --------------------------------------------------------------------------
//
//  CONFIDENTIAL and PROPRIETARY
//  COPYRIGHT (c) XXXX 2019
//
//  All rights are reserved. Reproduction in whole or in part is
//  prohibited without the written consent of the copyright owner.
//
//
//  ----------------------------------------------------------------------------
//                    Design Information
//  ----------------------------------------------------------------------------
//
//  File             $URL: http://.../ste.sv $
//  Author
//  Date             $LastChangedDate: 2019-02-15 08:18:28 +0100 (Fri, 15 Feb 2019) $
//  Last changed by  $LastChangedBy: kstrohma $
//  Version          $Revision: 2472 $
//
// Description       Generic shift register testbench
//
//  ----------------------------------------------------------------------------
//                    Revision History (written manually)
//  ----------------------------------------------------------------------------
//
//  Date        Author     Change Description
//  ==========  =========  ========================================================
//  2019-01-09  strohmay   Initial verison       

// Testbench  
module ste_dice_tb();

  logic        clk;            // System clock 
  logic        reset_ni;       // system cock reset (active low)  
  logic [15:0] sw      ;       // Switch
  logic        dice_done_o;    // Calculation of new value is done 
  logic [2:0]  dice_dout_o;    // Dice value 
  
  logic        btnC;           // Center
  logic        btnU;           // Up
  logic        btnD;           // Down

  int     dice_val_cnt [6:1];
  
  // DUT
  ste_dice_top dut(
    .clk             (clk   ), // I; System clock 
    .sw              (sw    ), // I; Switch
    .led             (      ), // O 16; LEDs    
    .btnC            (btnC  ),// I; Center 
    .btnU            (btnU  ),// I; Up 
    .btnD            (btnD  ),// I; Down 
    .btnR            (1'b0  ),// I; Left  
    .btnL            (1'b0  ),// I; Right

    // Seven Segment Display Outputs
    .seg()                      , // O; Segment  
    .an ()                      , // O; Anode of Seg0 ..3
    .dp ()                         // O; 
  );
  assign sw[4]   = reset_ni; // Reset 
  assign sw[3:0] = 4'b0011;  // Enable 2 dices
  
  always begin
    #5ns clk <= 1'b0;
    #5ns clk <= 1'b1;
  end
  
  
  initial begin 
    clk          = 1'b0;
    reset_ni     = 1'b0;
    btnC         = 1'b0;
    btnU         = 1'b0;
    btnD         = 1'b0;
    dice_val_cnt = {0, 0, 0, 0, 0, 0};
    
    @(negedge clk);
    reset_ni = 1'b1;
    repeat (20) begin
      @(negedge clk);
    end  
    
    // Check shift
    for (int i=0; i<1000; i=i+1) begin
      btnC = 1'b1;
      repeat (40 + i % 5)
        @(negedge clk);
      btnC = 1'b0;
      repeat (30)
        @(negedge clk);      
      while (!dice_done_o) begin
        @(negedge clk);
      end
      u_cov_dice.sample();
      dice_val_cnt[dice_dout_o]++;  
    end
    @(negedge clk);
    @(negedge clk);

    #1ms;
    btnC = 1'b1;
    repeat (200) @(negedge clk);
    btnC = 1'b0;

    #1ms;
    repeat (3) begin
      btnU = 1'b1;
      repeat (200) @(negedge clk);
      btnU = 1'b0;
      #1ms;
    end  

    #20ms;     
    $finish();
  end

  assign dice_done_o = dut.dice_done_o[0];    // Calculation of new value is done 
  assign dice_dout_o = dut.dice_dout_o[0];    // Dice value 


  // Functional coverage example ---------------------------------------------    
  // Cover group
  covergroup cov_dice @(negedge clk); 
    // Collect the values 
    cov_dout: coverpoint dice_dout_o {
      bins one   = {1};
      bins two   = {2};
      bins three = {3};
      bins four  = {4};
      bins five  = {5};
      bins six   = {6};
      bins wrong = default;
    }
    // Collect the rising edges of done --> represents the finished calculations
    cov_done_rise: coverpoint dice_done_o {
      bins rise = (0 => 1);
    }
    // Collect all douts when a rising edge of done occurs
    cov_edge: cross cov_dout, cov_done_rise;      
  endgroup 
  
  // Instantiate covergroup
  cov_dice u_cov_dice = new();
  
  
  // Assertion for checking --------------------------------------------------
  
  // Define property
  
  property dout_stable_when_done;
    @(posedge clk)
    disable iff(!reset_ni)
//    ( (dice_done_o ##1 dice_done_o) |-> (dice_dout_o == $past(dice_dout_o)));
    ( (dice_done_o) |-> (dice_dout_o == $past(dice_dout_o)));
  endproperty

  assert property (dout_stable_when_done) else 
    $error("dice_dout_o changed while dice_done_o is high");  
  
  
endmodule
