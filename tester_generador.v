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
        reset = 0;
        mdio_start = 0;
        t_data = 0;
        mdio_in = 0;

        // Wait for global reset to finish
        #10;
        reset = 1;
        #10

        // Write transaction
        t_data = 32'h9AB87652;
        mdio_start = 1'b1;
        #10;
        mdio_start = 1'b0;
        #670; //Finish write transaction

        //Read transaction
        t_data = 32'h2AB8AAAA;
        mdio_start = 1'b1;
        #10;
        mdio_start = 1'b0;
        #305;
        repeat (8) begin
            #20 mdio_in=1;
            #20 mdio_in=0;
        end
        
        // Continue simulating data bits as necessary
        #100 reset = 0;

        // End of simulation
        $finish;
    end
endmodule
