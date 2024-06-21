`include "tester1.v"

module mdio_testbench;

    mdio_tester tester();

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, mdio_testbench);
    end

endmodule

