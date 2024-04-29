`timescale 1ns/1ps
/*------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--	Revision 02 / Level 00
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Project Name	:	TS101
--	Device			:	Xilinx Artrix-7 xc7a35tcpg236-1
--	File Name		:	stopwatch_fsm.v
--	Module Name		:	STOPWATCH
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
--  01  00    2019/05/08  Yoshinori Ono   fixed for Basys3
--  02  00		2020/06/27	Yoshinori Ono	changed input/output declations to new ver.
--  03  00    2021/04/13	Hisato Miyauchi modify for Vivado ver 2020.2
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

`define	IDLE	4'b0001
`define	INIT	4'b0010
`define	START	4'b0100
`define	STOP	4'b1000

module	STOPWATCH(
    input			XRST,
    input			CLK,
    input			ON_OFF,
    input			RESET,
    input			START_STOP,
    output	[15:0]	TIME,
    output			POWER_ON,
    output			READY,
    output			TIMER_RUN
);

wire	[26:0]	S_CNT_MAX;
wire             XRST_B;

reg		[2:0]	R_MIN_X10;		// Minute, tens digit		max : 5
reg		[3:0]	R_MIN_X1;		// Minute, units digit		max : 9
reg		[2:0]	R_SEC_X10;		// Second, tens digit		max : 5
reg		[3:0]	R_SEC_X1;		// Second, units digit		max : 9
reg		[26:0]	R_CNT;
reg				POWER_ON;
reg				READY;
reg				TIMER_RUN;

reg		[3:0]	R_STATE;		// Current State
reg		[3:0]	R_NEXT;			// Next State

/*******************************************************
  NOTE: 以下の2行は、どちらかをコメントアウトすること！
 *******************************************************/
assign S_CNT_MAX	= 27'h5F5E100;	    // 実機用  (1/100MHz * 100000000 = 1s)
//assign S_CNT_MAX	= 27'h0000010;		// シミュレーション用

assign TIME	= {1'b0, R_MIN_X10, R_MIN_X1, 1'b0, R_SEC_X10, R_SEC_X1};

assign XRST_B = ~XRST;

// Control of LED
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		POWER_ON	<= 0;	// Active-high
		READY		<= 0;	// Active-high
		TIMER_RUN	<= 0;	// Active-high
	end else begin
		if (R_NEXT!=`IDLE) begin
			POWER_ON	<= 1;
		end else begin
			POWER_ON	<= 0;
		end
		if (R_NEXT==`INIT) begin
			READY		<= 1;
		end else begin
			READY		<= 0;
		end
		if (R_NEXT==`START) begin
			TIMER_RUN	<= 1;
		end else begin
			TIMER_RUN	<= 0;
		end
	end
end

// 10ms counter
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_CNT		<= 0;
	end else begin
		if (R_STATE==`IDLE || R_STATE==`INIT) begin
			R_CNT <= 0;
		end else begin
			if (R_STATE==`START) begin
				if (R_CNT==S_CNT_MAX-1) begin
					R_CNT <= 0;
				end else begin
					R_CNT <= R_CNT + 1;
				end
			end
		end
	end
end

// R_SEC_X1		// Seconds, units digit
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_SEC_X1 <= 0;
	end else begin
		if (R_STATE==`IDLE || R_STATE==`INIT) begin
			R_SEC_X1 <= 0;
		end else begin
			if (R_STATE==`START) begin
				if (R_CNT==S_CNT_MAX-1) begin
					if (R_SEC_X1==9) begin
						R_SEC_X1 <= 0;
					end else begin
						R_SEC_X1 <= R_SEC_X1 + 1;
					end
				end
			end
		end
	end
end

// R_SEC_X10		// Seconds, tens digit
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_SEC_X10 <= 0;
	end else begin
		if (R_STATE==`IDLE || R_STATE==`INIT) begin
			R_SEC_X10 <= 0;
		end else begin
			if (R_STATE==`START) begin
				if (R_CNT==(S_CNT_MAX-1) && R_SEC_X1==9) begin
					if (R_SEC_X10==5) begin
						R_SEC_X10 <= 0;
					end else begin
						R_SEC_X10 <= R_SEC_X10 + 1;
					end
				end
			end
		end
	end
end

// R_MIN_X1			// Minutes, units digit
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_MIN_X1 <= 0;
	end else begin
		if (R_STATE==`IDLE || R_STATE==`INIT) begin
			R_MIN_X1 <= 0;
		end else begin
			if (R_STATE==`START) begin
				if (R_CNT==(S_CNT_MAX-1) && R_SEC_X1==9 && R_SEC_X10==5) begin
					if (R_MIN_X1==9) begin
						R_MIN_X1 <= 0;
					end else begin
						R_MIN_X1 <= R_MIN_X1 + 1;
					end
				end
			end
		end
	end
end

// R_MIN_X10		// Minutes, tens digit
always @(posedge CLK or negedge XRST_B) begin
	if(!XRST_B) begin
		R_MIN_X10	<= 0;
	end else begin
		if (R_STATE==`IDLE || R_STATE==`INIT) begin
			R_MIN_X10	<= 0;
		end else begin
			if (R_STATE==`START) begin
				if (R_CNT==(S_CNT_MAX-1) && R_SEC_X1==9 && R_SEC_X10==5 && R_MIN_X1==9) begin
					if (R_MIN_X10==5) begin
						R_MIN_X10	<= 0;
					end else begin
						R_MIN_X10	<= R_MIN_X10 + 1;
					end
				end
			end
		end
	end
end

always @(posedge CLK or negedge XRST_B) begin
	if (!XRST_B) begin
		R_STATE <= `IDLE;
	end else begin
		R_STATE <= R_NEXT;
	end
end

always @(R_STATE or ON_OFF or START_STOP or RESET) begin
//	R_NEXT <= 4'b0000;
	case (R_STATE)
		`IDLE	: begin
					if (ON_OFF) begin
						R_NEXT	<= `INIT;
					end else begin
						R_NEXT	<= `IDLE;
					end
		end
		`INIT	: begin
					if (ON_OFF) begin
						R_NEXT	<= `IDLE;
					end else if (START_STOP) begin
						R_NEXT	<= `START;
					end else begin
						R_NEXT	<= `INIT;
					end
		end
		`START	: begin
					if (ON_OFF) begin
						R_NEXT	<= `IDLE;
					end else if (RESET) begin
						R_NEXT	<= `INIT;
					end else if (START_STOP) begin
						R_NEXT	<= `STOP;
					end else begin
						R_NEXT	<= `START;
					end
		end
		`STOP	: begin
					if (ON_OFF) begin
						R_NEXT	<= `IDLE;
					end else if (RESET) begin
						R_NEXT	<= `INIT;
					end else if (START_STOP) begin
						R_NEXT	<= `START;
					end else begin
						R_NEXT	<= `STOP;
					end
		end
		default	: begin
					R_NEXT	<= `IDLE;
		end
	endcase
end

endmodule
