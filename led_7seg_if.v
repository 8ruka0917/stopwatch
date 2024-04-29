`timescale 1ns/1ps
/*------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--	Revision 02 / Level 00
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Project Name	:	TS101
--	Device			:	Xilinx Artrix-7 xc7a35tcpg236-1
--	File Name		:	LED_7SEG_if.v
--	Module Name		:	LED_7SEG_IF
--	Author			:
--------------------------------------------------------------------------------
--	Tool
--------------------------------------------------------------------------------
--	Project Navigator version	:	Vivado 2018.3
--------------------------------------------------------------------------------
--	History
--------------------------------------------------------------------------------
--	Rev.Level	Data		Coded by		Contents
--	00	00		2004/05/28	ATEX)Eric B.
--  01  00      2019/05/08  Yoshinori Ono   fixed for Basys3
--  02  00		2020/06/27	Yoshinori Ono	changed input/output declations to new ver.
--  03  00      2021/04/13	Hisato Miyauchi modify for Vivado ver 2020.2
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module	LED_7SEG_IF(
    input			XRST,
    input			CLK,
    input			EN,
    input	[15:0]	DATA,
    output	[7:0]	LED_7SEG,
    output	[3:0]	LED_7COM
);

wire	[7:0]	S_ENC;
wire	[7:0]	S_DATA;
wire	[3:0]	S_COM;
wire        XRST_B;

assign XRST_B = ~XRST;

reg		[15:0]	R_CNT;
reg		[3:0]	R_COM;
reg		[7:0]	R_ENC;

wire           SIMULATION;

/*********************************
  NOTE: 以下のassign文について、
        シミュレーションなら1, 
        実機なら0にすること！
 *********************************/
assign SIMULATION = 0; // シミュレーション = 1, 実機 = 0

assign S_DATA	= (R_CNT[15:14]==2'b11) ? (DATA[15:12])  :
				  (R_CNT[15:14]==2'b10) ? (DATA[11:8])  :
				  (R_CNT[15:14]==2'b01) ? (DATA[7:4]) :
										  (DATA[3:0]);

/**********************************

  この下に、7セグのデコーダー部をファンクションを用いて記述してください。

 **********************************/

 function [6:0] F_ENC;
    input [3:0] DATA;
        case (DATA)
        0:         F_ENC = 7'b1000000;
        4'b0001:   F_ENC = 7'b1111001;
        4'b0010:   F_ENC = 7'b0100100;
        4'b0011:   F_ENC = 7'b0110000;
        4'b0100:   F_ENC = 7'b0011001;
        4'b0101:   F_ENC = 7'b0010010;
        4'b0110:   F_ENC = 7'b0000010;
        4'b0111:   F_ENC = 7'b1111000;
        4'b1000:   F_ENC = 7'b0000000;
        4'b1001:   F_ENC = 7'b0010000;
        default:   F_ENC = 7'b1111111;
        endcase
  endfunction
  

assign S_ENC[6:0]	= (!EN) ? 7'b111_1111 : F_ENC(S_DATA);
assign S_ENC[7]	= (!EN) ? 1 : (R_CNT[15:14]==2'b10)? 0 : 1;	// LED_7SEGment h: DP

always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_CNT	<= 0;
	end else begin
		if (EN) begin
		    if (SIMULATION) begin
			     R_CNT	<= R_CNT + 15'h4000;
			end else begin
			     R_CNT	<= R_CNT + 1;
			end
		end else begin
			R_CNT	<= 0;
		end
	end
end

assign S_COM	= (!EN)                ? 4'b1111 :
                  (R_CNT[13:12]==2'b11)? 4'b1111 :
				  (R_CNT[15:14]==2'b11)? 4'b0111 :
				  (R_CNT[15:14]==2'b10)? 4'b1011 :
				  (R_CNT[15:14]==2'b01)? 4'b1101 : 4'b1110;

always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_COM	<= 4'b1111;
		R_ENC	<= 8'b0000_0000;
	end else begin
		R_COM	<= S_COM;
		R_ENC	<= S_ENC;
	end
end

assign LED_7COM	= R_COM;
assign LED_7SEG	= R_ENC;

endmodule
