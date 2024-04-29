`timescale 1ns/1ps
/*------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--	Revision 02 / Level 00
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Project Name	:	TS101
--	Device			:	Xilinx Artrix-7 xc7a35tcpg236-1
--	File Name		:	debouncer.v
--	Module Name		:	DEBOUNCER
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
--  03  00    2021/04/13	Hisato Miyauchi modify for Vivado ver 2020.2
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module	DEBOUNCER(
    input		XRST,
    input		CLK,
    input		XDIN,
    output		XDOUT
);

wire	[16:0]	S_CNT_MAX;
wire			S_XDOUT;
wire            XRST_B;

assign XRST_B = ~XRST;

reg		[16:0]	R_CNT;
reg		[2:0]	R_XDIN;
reg		[1:0]	R_XDOUT;

/*******************************************************
   NOTE: 以下の2行は、どちらかをコメントアウトすること！ 
 *******************************************************/
assign S_CNT_MAX = 17'h186A0;    // 実機用  (1/100MHz * 100000 = 1ms)
//assign S_CNT_MAX	= 17'h00010;   // シミュレーション用

// Input -> IFF -> FF -> FF
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_XDIN	<= 3'b000;
	end else begin
		R_XDIN[0]	<= XDIN;
		R_XDIN[1]	<= R_XDIN[0];
		R_XDIN[2]	<= R_XDIN[1];
	end
end

always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_CNT	<= 0;
	end else begin
		if (R_CNT==0) begin
			if (!R_XDIN[2] && R_XDIN[1]) begin
				R_CNT	<= 1;
			end
		end else begin
			if (R_CNT==S_CNT_MAX-1) begin
				R_CNT	<= 0;
			end else begin
				R_CNT	<= R_CNT + 1;
			end
		end
	end
end

assign S_XDOUT	= (R_CNT==S_CNT_MAX[16:1] && R_XDIN[2:1]==2'b11)? 1 : 0;

always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_XDOUT	<= 2'b00;
	end else begin
		R_XDOUT[0]	<= S_XDOUT;
		R_XDOUT[1]	<= ~S_XDOUT & R_XDOUT[0];
	end
end

assign XDOUT		= R_XDOUT[1];

endmodule
