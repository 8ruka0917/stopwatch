`timescale 1ns/1ps

// 2022.5.14  Modified and checked by K. Usami


module TS101_test();

parameter PERIOD = 10;

// Inputs
    reg XRST;
    reg CLK;
    reg [2:0] KEY;


// Outputs
    wire [2:0] LED;
    wire [3:0] LED_7COM;
    wire [7:0] LED_7SEG;



// Instantiate the uut
    TS101 uut (
        .XRST(XRST), 
        .CLK(CLK), 
        .KEY(KEY), 
        .LED(LED), 
        .LED_7COM(LED_7COM), 
        .LED_7SEG(LED_7SEG)
        );


// Initialize Inputs

    initial begin
                      XRST = 1;	// Power on reset on
                      CLK = 0;
                      KEY[2] = 0;
                      KEY[1] = 0;
                      KEY[0] = 0;
     #(PERIOD*10)     XRST   = 0;	// Power on reset off
     #(PERIOD*10)     KEY[0] = 1;	// Stopwatch •\Ž¦ on						
     #(PERIOD*10)     KEY[0] = 0;
     #(PERIOD*10)     KEY[2] = 1;	// Stopwatch start
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*100000) KEY[2] = 1;	// Stopwatch stop
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*10)     KEY[2] = 1;	// Stopwatch start
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*10)     KEY[2] = 1;	// Stopwatch stop
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*10)     KEY[1] = 1;	// Stopwatch reset on
     #(PERIOD*10)     KEY[1] = 0;			 
     #(PERIOD*10)     KEY[2] = 1;	// Stopwatch start
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*10)     KEY[0] = 1;	// Stopwatch •\Ž¦ off 
     #(PERIOD*10)     KEY[0] = 0;
     #(PERIOD*10)     KEY[0] = 1;	// Stopwatch •\Ž¦ on 
     #(PERIOD*10)     KEY[0] = 0;
     #(PERIOD*10)     KEY[2] = 1;	// Stopwatch start
     #(PERIOD*10)     KEY[2] = 0;
     #(PERIOD*10)     XRST	 = 1;	// Power on reset on
     #(PERIOD*10)     XRST 	 = 0;	// Power on reset off
     $stop;
    
    end
    
    always #(PERIOD/2) CLK = ~CLK; 

endmodule

