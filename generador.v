module mdio_transaction_generator (
    input wire clk,
    input wire reset,
    input wire mdio_start,
    input [31:0] t_data,
    output reg mdc,
    output reg mdio_out,
    output reg mdio_oe,
    input wire mdio_in,
    output reg [15:0] rd_data,
    output reg data_rdy
);

    // Internal signals
    reg [2:0] state;
    reg [5:0] count;

    // State encoding
    localparam IDLE = 3'd0,
               START = 3'd1,
               READ = 3'd2,
               WRITE = 3'd3,
               DONE = 3'd4;

    // Generate MDC with half the frequency of clk
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mdc <= 0;
        end else begin
            mdc <= ~mdc;
        end
    end

    // State machine for MDIO transaction
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            mdio_out <= 0;
            mdio_oe <= 0;
            rd_data <= 0;
            data_rdy <= 0;
            count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (mdio_start == 1) begin
                        state <= START;
                        count <= 0;
                        data_rdy <= 0;
                    end
                end
                START: begin
                    if (t_data[29:28] == 2'b10) begin  // Read
                        state <= READ;
                    end else if (t_data[29:28] == 2'b01) begin  // Write
                        state <= WRITE;
                    end else begin
                        state <= DONE;
                    end
                end
                READ: begin
                    if (count < 32) begin
                        if (count<16) begin
                            mdio_oe <= 1;
                        end
                        if (count >= 16) begin
                            mdio_oe <= 0;
                            rd_data[31 - count] <= mdio_in;
                            mdio_oe <= 0;
                        end
                        count <= count + 1;
                    end else begin
                        data_rdy <= 1;
                        state <= DONE;
                    end
                end
                WRITE: begin
                    mdio_oe <= 1;
                    if (count < 32) begin
                        mdio_out <= t_data[31 - count];
                        count <= count + 1;
                    end else begin
                        state <= DONE;
                        mdio_oe <= 0;
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
