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
// Description       Dice implementation. 
//                     Includes a synchronization and debouncer for input trig_i
//
//  ----------------------------------------------------------------------------
//                    Revision History (written manually)
//  ----------------------------------------------------------------------------
//
//  Date        Author     Change Description
//  ==========  =========  ========================================================
//  2019-01-09  strohmay   Initial verison       

`default_nettype none
module ste_dice_top (
  input   wire                clk   , // I; System clock (100MHz)

  // Switches
  input  wire  [15:0]         sw    , // I 16; Switches
  
  // LEDs
  output logic [15:0]         led   , // O 16; LEDs

  // Push Button Inputs	 
  input  wire                 btnC  , // I  1; Center 
  input  wire                 btnU  , // I  1; Up 
  input  wire                 btnD  , // I  1; Down 
  input  wire                 btnR  , // I  1; Left  
  input  wire                 btnL  , // I  1; Right

  // Seven Segment Display Outputs
  output logic [6:0]          seg   , // O 7; Segment  
  output logic [3:0]          an    , // O 4; Anode of Seg0 ..3
  output logic                dp      // O 1; Segement dot
);
  

  
  // -------------------------------------------------------------------------
  // Definition 
  // -------------------------------------------------------------------------
  logic               reset_ni        ; // I; system cock reset (active low)  

  // Trigger
  logic               trig_sync_deb;
  logic               trig_sync_deb_pls;
  logic [3:0]         sw_syn_deb;
  
  logic [1:0]         dice_done_o      ; // 
  logic [2:0]         dice_dout_o [3:0]; //  
    
  logic [15:0] x;    
  logic  [3:0] x_dp;   
  
 
  // -------------------------------------------------------------------------
  // Implementation
  // -------------------------------------------------------------------------
  assign led[15:0]  = sw[15:0];
  
  assign reset_ni = sw[4];   
  
  // Trigger signal handling -------------------------------------------------
  // Debounce & Sync 
  ste_debounce #(
    .SYNC (1), 
    .CNT_W(4)
  ) i0_debounce (
    .clk         (clk),                 // I; System clock 
    .reset_ni    (reset_ni),            // I; active loaw reset 
    .din_i       (btnC),                // I; Data in to be debounced
    .deb_rise_i  (4'hf),                // I; maximal count value
    .deb_fall_i  (4'hf),                // I; maximal count value
    .dout_o      (trig_sync_deb)        // O; Debounced data out
  );
  
  // Pulse generation
  ste_edge #(
    .SYNC (0),
    .RISE (1),
    .FALL (0) 
  ) i0_pls(
    .clk            (clk              ), // I; System clock 
    .reset_ni       (reset_ni         ), // I; system cock reset (active low)  
    .din_i          (trig_sync_deb    ), // I; Input data
    .edge_det_o     (trig_sync_deb_pls)  // O; Edge detected
  );
  

  // Dice function -----------------------------------------------------------
  genvar i;
  generate   
    for (i=0; i<4; i++) begin: dice
      ste_debounce #(
        .SYNC (1), 
        .CNT_W(4)
       ) i0_debounce (
         .clk         (clk          ),   // I; System clock 
         .reset_ni    (reset_ni     ),   // I; active loaw reset 
         .din_i       (sw[i]        ),   // I; Data in to be debounced
         .deb_rise_i  (4'hf         ),   // I; maximal count value
         .deb_fall_i  (4'hf         ),   // I; maximal count value
         .dout_o      (sw_syn_deb[i])    // O; Debounced data out
       );
    
      // Dice 
      ste_dice_module #(
        .INITIAL_VALUE(3*i+5)
      ) iu_ste_dice_module(
        .clk            (clk              ), // I 1; System clock 
        .reset_ni       (reset_ni         ), // I 1; system cock reset (active low)  
        .trig_pls       (trig_sync_deb_pls), // I 1; trigger pulse 
        .dice_done_o    (dice_done_o[i]   ), // O 1; Done  
        .dice_dout_o    (dice_dout_o[i]   )  // O 4; Value
      );
      
      assign x[(4*(i+1)-1) -: 4] = (sw_syn_deb[i]) ? {1'b0, dice_dout_o[i]} : 4'hb;
      assign x_dp[i]             = ~sw_syn_deb[i];
      
    end      
  endgenerate  

  // Seven segment controller  
  seg7_ctrl_lint i0_seg7_ctrl(
    .rst_ni(reset_ni   ),
    .clk   (clk        ),
    .en    (1'b1       ),
    .dim   (4'b1000    ), // I  4; Dimming 
    .x     (x[15:0]    ),
    .x_dp  (x_dp       ), 
    .seg   (seg        ),
    .an    (an         ),
    .dp    (dp         )
  );

  
endmodule
`default_nettype wire  