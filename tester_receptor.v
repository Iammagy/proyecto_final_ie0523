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
    reg [15:0] RD_DATA;
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
        .RD_DATA(RD_DATA),
        .WR_STB(WR_STB)
    );

    initial begin
        // Initialize signals
        MDC = 0;
        RESET = 0;
        MDIO_OUT = 0;
        MDIO_OE = 0;
        RD_DATA = 16'hABCD;
        #10 RESET = 1;

        // Simulate MDIO write transaction
        MDIO_OE = 1;
        #5 MDIO_OUT = 1;  // Start bit
        #8 MDIO_OUT = 0;  // Opcode (Write)
        #4 MDIO_OUT = 1;
        #9 MDIO_OUT = 0;
        #6 MDIO_OUT = 0;  // PHY address
        #11 MDIO_OUT = 1;
        #15 MDIO_OUT = 1;
        #11 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Register address
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Data
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Stop bit
        #10 MDIO_OUT = 0;

        // Simulate MDIO read transaction
        #50;
        MDIO_OE = 1;
        #10 MDIO_OUT = 1;  // Start bit
        #10 MDIO_OUT = 0;  // Opcode (Read)
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;  // PHY address
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Register address
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Data
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 0;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;
        #10 MDIO_OUT = 1;  // Stop bit
        #10 MDIO_OUT = 0;

        #100 $finish;
    end

    always #5 MDC = ~MDC;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;
    end
endmodule
