`include "parte1.v"

module mdio_tester;

    // Inputs
    reg clk;
    reg reset;
    reg mdio_start;
    output reg [31:0] t_data;
    reg mdio_in;

    // Outputs
    wire mdc;
    wire mdio_out;
    wire mdio_oe;
    input [15:0] rd_data;
    wire data_rdy;

    // Instantiate the Unit Under Test (UUT)
    mdio_transaction_generator uut (
        .clk(clk),
        .reset(reset),
        .mdio_start(mdio_start),
        .t_data(t_data),
        .mdc(mdc),
        .mdio_out(mdio_out),
        .mdio_oe(mdio_oe),
        .mdio_in(mdio_in),
        .rd_data(rd_data),
        .data_rdy(data_rdy)
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


