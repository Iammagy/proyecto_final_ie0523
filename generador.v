module mdio_transaction_generator (
    input wire clk,
    input wire reset,
    input wire mdio_start,
    input [31:0] t_data,
    input wire mdio_in,
    output reg mdc,
    output reg mdio_out,
    output reg mdio_oe,
    output reg [15:0] rd_data,
    output reg data_rdy
);

    // Internal signals
    reg [4:0] state;    // FIX: One hot
    reg [5:0] count;

    // State encoding
    localparam IDLE = 5'd1, // FIX: One hot
               START = 5'd2,
               READ = 5'd4,
               WRITE = 5'd8,
               DONE = 5'd16;

    // Generate MDC with half the frequency of clk
    always @(posedge clk or negedge reset) begin    // FIX: Reset active low
        if (!reset) begin
            mdc <= 0;
        end else begin
            mdc <= ~mdc;
        end
    end

    // State machine for MDIO transaction
    always @(posedge clk or negedge reset) begin
        if (!reset) begin // FIX: Reset must be active in low.
            state <= IDLE;
            mdio_out <= 0;
            mdio_oe <= 0;
            rd_data <= 0;
            data_rdy <= 0;
            count <= 0;
        end else begin
            case (state)
                IDLE: begin // quiza idle y star se podria hacer en un mismo estado. 
                    if (mdio_start == 1) begin // porque cuand mdio_star esta en 1 se pasa a star inmed.
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
                        state <= DONE;  //??? porque done en el idle?
                    end
                end
                READ: begin
                    if (count < 32) begin //READ
                        if (count<16) begin
                            mdio_oe <= 1;
                        end
                        if (count >= 16) begin
                            mdio_oe <= 0;
                            rd_data[31 - count] <= mdio_in; //rd data es de 16 bits, no de 32
                                                            // hacer [31- count] produciria un error?
                        end
                        count <= count + 1;
                    end else begin
                        data_rdy <= 1;
                        state <= DONE;
                    end
                end
                WRITE: begin // escritura en alto los primeros 16 bits
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