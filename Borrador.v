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
    reg state;
    //parameter IDLE = 1'b0, ACTIVE = 1'b1;

    always @(posedge MDC) begin
    if (!RESET) begin  //RESET activo en bajo
        MDIO_DONE <= 0;
        MDIO_IN <= 0;
        ADDR <= 0;
        WR_DATA <= 0;
        WR_STB <= 0;
        bit_count <= 0;
        shift_reg <= 0;
        state <= IDLE;
        end 
    end 

//comunicacion usando el clk: mdc
always @(posedge mdc) begin     
    case (state)
        READ: begin
            if (count < 32) begin //READ
                if (count >= 16) begin
                    mdio_oe <= 0;
                    rd_data[31 - count] <= mdio_in; 
                end
                count <= count + 1;
            end 
        end
        WRITE: begin // escritura en alto los primeros 16 bits
            if (count < 32) begin
                mdio_out <= t_data[31 - count];
                count <= count + 1;
            end 
        end
    endcase
end
 

// Maquina de estados del resto:
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
                        state <= DONE; 
                    end
                end

                READ: begin
                    if (count < 32) begin //READ
                        if (count<16) begin
                            mdio_oe <= 1;
                        end
                        if (count >= 16) begin
                            mdio_oe <= 0;
                        end
                    end else begin
                        data_rdy <= 1;
                        state <= DONE;
                    end
                end
                WRITE: begin
                    mdio_oe <= 1;
                    if (count >= 32) begin
                        state <= DONE;
                        mdio_oe <= 0;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end
        endcase


endmodule