`default_nettype wire
module seg7_ctrl_lint(
input  wire         rst_ni, 
input  wire         clk   , 
input  wire         en    , 
input  wire  [ 3:0] dim   , 
input  wire  [15:0] x     , 
input  wire  [ 3:0] x_dp  , 
output logic [ 6:0] seg   , 
output logic        dp    , 
output logic [ 3:0] an      
);
	 
logic [3:0]  VqSJRS0d8tqgI;       
logic        GE6vHnl8YEojYx;      
logic        llKvI78XZcKQK;       
logic        qg5RWD73ZuSDlNCJ9;   
logic [19:0] FiRSVc;       
logic        OGGHc6P;      
logic        nkwPCS;       
logic        MZ1EP5FDep;   
logic [15:0] rSHM;    	 
logic  [3:0] s4CqFm4;
logic [3:0]  vKnsaL;
logic        kYro; 
logic [1:0]  pu33OGX49Mt;
logic [3:0]  OnIzfx7;
logic        rRe4PYIwWF;
logic [6:0]  hNVOfa;
logic       wmK6uzY;
logic [3:0] JKpCB;  
logic       m8ohw;  
logic [6:0] COglt7; 
enum logic [1:0] {
pJP7=2'h0, 
WW0Q5=2'h1, 
G0x=2'h2  
} NBfaULrhpGAM, RUkH5ndLShwGGB;
always_ff @(posedge clk or negedge rst_ni) begin
if (~rst_ni) begin
VqSJRS0d8tqgI<=4'h0;
end else begin
if (GE6vHnl8YEojYx) begin
VqSJRS0d8tqgI<=20'h0;
end else if (llKvI78XZcKQK) begin
VqSJRS0d8tqgI<=VqSJRS0d8tqgI+1'b1;
end
end    
end
assign qg5RWD73ZuSDlNCJ9=(VqSJRS0d8tqgI >=4'h8);
always_ff @(posedge clk or negedge rst_ni) begin
if (~rst_ni) begin
FiRSVc<=20'h000000;
end else begin
if (OGGHc6P) begin
FiRSVc<=20'h0;
end else if (nkwPCS) begin
if (~llKvI78XZcKQK | qg5RWD73ZuSDlNCJ9) begin 
FiRSVc<=FiRSVc+1'b1;
end  
end
end    
end
assign MZ1EP5FDep=(FiRSVc==20'hf_ffff);
always_ff @(posedge clk, negedge rst_ni) begin
if (~rst_ni) begin
NBfaULrhpGAM<=pJP7;
end else begin    
NBfaULrhpGAM<=RUkH5ndLShwGGB;
end
end  
always_comb begin
RUkH5ndLShwGGB=NBfaULrhpGAM;   
kYro=1'b0;
GE6vHnl8YEojYx=1'b0;
llKvI78XZcKQK=1'b0; 
OGGHc6P=1'b0;
nkwPCS=1'b0;
wmK6uzY=1'b0;
case (NBfaULrhpGAM)     
pJP7: begin
if (en) begin
kYro=1'b1;
OGGHc6P=1'b1;
RUkH5ndLShwGGB=WW0Q5;
end else begin 
wmK6uzY=1'b1;
end 
end
WW0Q5: begin
nkwPCS=1'b1;
if (MZ1EP5FDep) begin
if (vKnsaL !=4'h0) begin
GE6vHnl8YEojYx=1'b1;
OGGHc6P=1'b1;
RUkH5ndLShwGGB=G0x;
end else begin
RUkH5ndLShwGGB=pJP7;
end 
end    
end
G0x: begin
llKvI78XZcKQK=1'b1; 
nkwPCS=1'b1;
wmK6uzY=1'b1;
if (FiRSVc=={vKnsaL, 16'hffff}) begin
RUkH5ndLShwGGB=pJP7;
end
end
default: begin 
RUkH5ndLShwGGB=pJP7;
end
endcase
end    
always @(posedge clk or negedge rst_ni) begin
if (~rst_ni) begin	
rSHM<=16'h0000;
s4CqFm4<=4'b0000;
vKnsaL<=4'h0;
end else begin
if (kYro) begin  
rSHM<=x;
s4CqFm4<=x_dp;
vKnsaL<=dim;
end  
end
end    
assign pu33OGX49Mt=FiRSVc[19:18];
always_comb begin
case(pu33OGX49Mt)
2'b00  : begin OnIzfx7<=rSHM[ 3: 0]; rRe4PYIwWF<=s4CqFm4[0]; end  
2'b01  : begin OnIzfx7<=rSHM[ 7: 4]; rRe4PYIwWF<=s4CqFm4[1]; end  
2'b10  : begin OnIzfx7<=rSHM[11: 8]; rRe4PYIwWF<=s4CqFm4[2]; end  
2'b11  : begin OnIzfx7<=rSHM[15:12]; rRe4PYIwWF<=s4CqFm4[3]; end  
default: begin OnIzfx7<=rSHM[ 3: 0]; rRe4PYIwWF<=s4CqFm4[0]; end 
endcase
end
always @(*) begin
case(OnIzfx7)
0:hNVOfa=7'b1000000;
1:hNVOfa=7'b1111001;
2:hNVOfa=7'b0100100;
3:hNVOfa=7'b0110000;
4:hNVOfa=7'b0011001;
5:hNVOfa=7'b0010010;
6:hNVOfa=7'b0000010;
7:hNVOfa=7'b1111000;
8:hNVOfa=7'b0000000;
9:hNVOfa=7'b0010000;
'hA:hNVOfa=7'b0111111; 
'hB:hNVOfa=7'b1111111; 
'hC:hNVOfa=7'b1110111;    
default: hNVOfa=7'b0000000; 
endcase
end
always_ff @(posedge clk or negedge rst_ni) begin
if (~rst_ni) begin
JKpCB<=4'b1111;
COglt7<=7'b0000000;
m8ohw<=1'b1;
end else begin
if (wmK6uzY) begin
JKpCB<=4'b1111;
COglt7<=7'b0000000;
m8ohw<=1'b1;
end else begin        
JKpCB<=4'b1111;
JKpCB[pu33OGX49Mt]<=1'b0;            
COglt7<=hNVOfa;   
m8ohw<=~rRe4PYIwWF;   
end
end    
end
assign an=JKpCB;
assign dp=m8ohw;
assign seg=COglt7;
endmodule
