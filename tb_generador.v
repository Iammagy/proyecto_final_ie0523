`include "generador.v"
`include "tester_generador.v"

module mdio_generador_testbench;
    wire clk;
    wire reset;
    wire mdio_start;
    wire [31:0] t_data;
    wire mdio_in;
    wire mdc;
    wire mdio_out;
    wire mdio_oe;
    wire [16:0]rd_data;
    wire data_rdy;

    initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, mdio_generador_testbench);
    end

    mdio_transaction_generator DUT(
    .clk(clk),
    .reset(reset),
    .mdio_start(mdio_star),
    .t_data(t_data),
    .mdio_in(mdio_in),
    .mdc(mdc),
    .mdio_out(mdio_out),
    .mdio_oe(mdio_oe),
    .rd_data(rd_data),
    .data_rdy(rd_data)
    );

    mdio_tester tester(
    .clk(clk),
    .reset(reset),
    .mdio_start(mdio_star),
    .t_data(t_data),
    .mdio_in(mdio_in)
    );
endmodule

