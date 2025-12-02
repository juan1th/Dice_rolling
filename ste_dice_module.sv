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
module ste_dice_module #(
  parameter bit[7:0] INITIAL_VALUE = 8'b0000_0001
) (
  input   wire                clk       , // I; System clock 
  input   wire                reset_ni  , // I; system reset (active low)  
  input   wire                trig_pls  , // I; trigger pulse (from btnC, debounced + edge)
  output logic                dice_done_o, // O; Dice rolling done  
  output logic [2:0]          dice_dout_o  // O; Dice result (1..6)
);

  // -------------------------------------------------------------------------
  // Definition 
  // -------------------------------------------------------------------------
  
  // LFSR and dice logic
  logic [7:0] lfsr_ff;
  logic [2:0] lfsr_lsb;
  logic [2:0] dice_value;

  // Trigger sync and edge detection
  logic trig_sync_ff, trig_prev_ff;
  logic roll_start;

  // Rolling control
  logic        is_it_rolling;
  logic [6:0]  roll_cnt_ff;
  logic        roll_done;

  // -------------------------------------------------------------------------
  // Random value generation
  // -------------------------------------------------------------------------

  // LSFR using the following 8bit polynomial x8 + x6 + x5 + x4 + 1.
  assign lfsr_lsb = lfsr_ff[2:0];

  // Map 3 LSBs to dice value 1..6
  always_comb begin
    case (lfsr_lsb)
      3'd0: dice_value = 3'd6;
      3'd1: dice_value = 3'd1;
      3'd2: dice_value = 3'd2;
      3'd3: dice_value = 3'd3;
      3'd4: dice_value = 3'd4;
      3'd5: dice_value = 3'd5;
      default: dice_value = 3'd1;
    endcase
  end

  // -------------------------------------------------------------------------
  // Trigger sync + edge detect
  // -------------------------------------------------------------------------

  always_ff @(posedge clk or negedge reset_ni) begin
    if (!reset_ni) begin
      trig_sync_ff <= 1'b0;
      trig_prev_ff <= 1'b0;
    end else begin
      trig_sync_ff <= trig_pls;
      trig_prev_ff <= trig_sync_ff;
    end
  end

  // One-clock start pulse when trig_pls goes 0 -> 1
  assign roll_start = trig_sync_ff & ~trig_prev_ff;

  // -------------------------------------------------------------------------
  // Rolling state + counter
  // -------------------------------------------------------------------------

  // Rolling flag
  always_ff @(posedge clk or negedge reset_ni) begin
    if (!reset_ni) begin
      is_it_rolling <= 1'b0;
    end else if (roll_start) begin
      is_it_rolling <= 1'b1;
    end else if (roll_done) begin
      is_it_rolling <= 1'b0;
    end
  end

  // Counter: decide how long we roll (100 cycles)
  assign roll_done = (roll_cnt_ff == 7'd100) && is_it_rolling;

  always_ff @(posedge clk or negedge reset_ni) begin
    if (!reset_ni) begin
      roll_cnt_ff <= 7'd0;
    end else if (roll_start) begin
      roll_cnt_ff <= 7'd0;
    end else if (is_it_rolling && !roll_done) begin
      roll_cnt_ff <= roll_cnt_ff + 1'b1;
    end
  end

  // -------------------------------------------------------------------------
  // LFSR update
  // -------------------------------------------------------------------------

  always_ff @(posedge clk or negedge reset_ni) begin
    if (!reset_ni) begin
      lfsr_ff <= INITIAL_VALUE; // different per dice via parameter
    end else if (is_it_rolling) begin
      // feedback = x^8 + x^6 + x^5 + x^4 + 1
      lfsr_ff <= {lfsr_ff[6:0], lfsr_ff[7] ^ lfsr_ff[5] ^ lfsr_ff[4] ^ lfsr_ff[3]};
    end
  end

  // -------------------------------------------------------------------------
  // Outputs
  // -------------------------------------------------------------------------

  // Done is high when rolling has finished
  assign dice_done_o = roll_done;

  // While rolling you could show 0 or keep last value;
  // testbench cares only when dice_done_o is high.
  always_ff @(posedge clk or negedge reset_ni) begin
    if (!reset_ni) begin
      dice_dout_o <= 3'd0;
    end else if (roll_done) begin
      dice_dout_o <= dice_value;
    end
  end

endmodule
`default_nettype wire