module mdio_tester
(
    output reg clk,
    output reg reset,
    output reg mdio_start,
    output reg [31:0] t_data,
    output reg mdio_in
);
    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    // Test sequences
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        mdio_start = 0;
        t_data = 0;
        mdio_in = 0;

        // Wait for global reset to finish
        #100;
        reset = 0;
        #10
        

        // Write transaction
        t_data = 32'h6AB87654;
        mdio_start = 1'b1;
        #10;
        mdio_start = 1'b0;
        #175;

        mdio_in=1;
        #10 mdio_in=0;

        #10 mdio_in=1;
             #10 mdio_in=0;

       #10 mdio_in=1;
             #10 mdio_in=0;
        
        // Continue simulating data bits as necessary
        #500; // Wait for the remaining cycles

        #200;
        reset = 1;

        // End of simulation
        $finish;
    end

endmodule


