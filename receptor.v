module mdio_receptor (
    input wire MDC,
    input wire RESET,
    input wire MDIO_OUT,
    input wire MDIO_OE,
    output reg MDIO_DONE,
    output reg MDIO_IN,
    output reg [4:0] ADDR,
    output reg [15:0] WR_DATA,
    input wire [15:0] RD_DATA,
    output reg WR_STB
);

    reg [4:0] bit_count;
    reg [31:0] shift_reg;
    reg state;
    parameter IDLE = 1'b0, ACTIVE = 1'b1;

    always @(posedge MDC or negedge RESET) begin
        if (!RESET) begin  //RESET activo en bajo
            MDIO_DONE <= 0;
            MDIO_IN <= 0;
            ADDR <= 0;
            WR_DATA <= 0;
            WR_STB <= 0;
            bit_count <= 0;
            shift_reg <= 0;
            state <= IDLE;
        end else if (MDIO_OE) begin
            if (state == IDLE) begin
                bit_count <= 0;
                shift_reg <= 0;
                state <= ACTIVE;
            end else if (state == ACTIVE) begin
                shift_reg <= {shift_reg[30:0], MDIO_OUT};
                bit_count <= bit_count + 1;
                if (bit_count == 31) begin
                    state <= IDLE;
                    MDIO_DONE <= 1;
                    if (shift_reg[31:30] == 2'b01) begin // Write operation
                        ADDR <= shift_reg[29:25];
                        WR_DATA <= shift_reg[15:0];
                        WR_STB <= 1;
                    end else if (shift_reg[31:30] == 2'b10) begin // Read operation
                        ADDR <= shift_reg[29:25];
                        MDIO_IN <= RD_DATA;
                    end
                end
            end
        end else begin
            WR_STB <= 0;
            MDIO_DONE <= 0;
        end
    end
endmodule
