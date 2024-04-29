`timescale 1ns/1ps
/*------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--	Revision 02 / Level 00
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Project Name	:	TS101
--	Device			:	Xilinx Artrix-7 xc7a35tcpg236-1
--	File Name		:	ts101.v
--	Module Name		:	TS101
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

module TS101(
	input        XRST,        // Active-high reset
	input        CLK,         // Input clock 100MHz
	input  [2:0] KEY,         // Push Switch I/F
	output [2:0] LED,         // LED I/F
	output [3:0] LED_7COM,    // 7-SEGment LED I/F
	output [7:0] LED_7SEG     // 7-SEGment LED I/F
);

/**********************************

  この下に、内部配線・インスタンシエーションの記述を追加してください。

 **********************************/
    
    wire S_KEY0;
    wire S_KEY1;
    wire S_KEY2;
    wire [15:0] S_TIME;

    DEBOUNCER inst1 (
    .CLK(CLK), .XRST(XRST), .XDIN(KEY[2]), .XDOUT(S_KEY2)
    );
    
     DEBOUNCER inst2 (
    .CLK(CLK), .XRST(XRST), .XDIN(KEY[1]), .XDOUT(S_KEY1)
    );
    
     DEBOUNCER inst3 (
    .CLK(CLK), .XRST(XRST), .XDIN(KEY[0]), .XDOUT(S_KEY0)
    );
    
    STOPWATCH inst4 (
    .CLK(CLK), .XRST(XRST), .START_STOP(S_KEY2), .RESET(S_KEY1), .ON_OFF(S_KEY0), .TIMER_RUN(LED[2]), .READY(LED[1]), .POWER_ON(LED[0]), .TIME(S_TIME)
    );
    
    LED_7SEG_IF inst5 (
    .CLK(CLK), .XRST(XRST), .EN(LED[0]), .DATA(S_TIME), .LED_7SEG(LED_7SEG), .LED_7COM(LED_7COM)
    );
endmodule
