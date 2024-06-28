`include "receptor.v"

module tb_mdio_receptor;
    reg MDC;
    reg RESET;
    reg MDIO_OUT;
    reg MDIO_OE;
    wire MDIO_DONE;
    wire MDIO_IN;
    input [4:0] ADDR;
    input [15:0] WR_DATA;
    wire WR_STB;

    mdio_receptor uut (
        .MDC(MDC),
        .RESET(RESET),
        .MDIO_OUT(MDIO_OUT),
        .MDIO_OE(MDIO_OE),
        .MDIO_DONE(MDIO_DONE),
        .MDIO_IN(MDIO_IN),
        .ADDR(ADDR),
        .WR_DATA(WR_DATA),
        .WR_STB(WR_STB)
    );

    initial begin
        // Initialize signals
        MDC = 0;
        RESET = 0;
        MDIO_OUT = 0;
        MDIO_OE = 0;
        #10 RESET = 1;

        // Simulate MDIO write transaction
        #5 MDIO_OE = 1;

        // Start bit
        #10 MDIO_OUT = 0;  
        #10 MDIO_OUT = 1;

        // Opcode (Write)
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;

        // PHY address (7)
        #10 MDIO_OUT = 0;  
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;

        // Register address and TA
        #10 MDIO_OUT = 1;  
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1; 
        
         // Data (43AE)
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 0;

        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;

        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;

        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  
        #10 MDIO_OUT = 0;
        MDIO_OE = 0;


        // Simulate MDIO read transaction
        // Start bit
        #100 MDIO_OE = 1;

        // Start bit
        #10 MDIO_OUT = 0;  
        #10 MDIO_OUT = 1;

        // Opcode (Read)
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;

        // PHY address (3)
        #10 MDIO_OUT = 0;  
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;

        // Register address and TA
        #10 MDIO_OUT = 1;  
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1; 
        MDIO_OE = 0;

        #300 $finish;
    end

    always #5 MDC = ~MDC;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;
        $dumpvars(0, uut.mem[7]);
        $dumpvars(0, uut.mem[3]);

    end
endmodule
