module mdio_receptor (
    input wire MDC,
    input wire RESET,
    input wire MDIO_OUT,
    input wire MDIO_OE,
    input wire CLK,
    input wire [15:0] RD_DATA,
    output reg MDIO_DONE,
    output reg MDIO_IN,
    output reg [4:0] ADDR,
    output reg [4:0] REGADR,
    output reg [15:0] WR_DATA,
    output reg WR_STB

);

    reg [3:0] state, prox_state;
    reg [31:0] frame;       // registro interno que almacena los 32 bits del "frame" de la trans MDIO.
    reg [4:0] counter;            //debe contar de 0 hasta 31 (5bits)
    localparam IDLE = 4'd1, // One hot
               READ = 4'd2,
               WRITE = 4'd4,
               ACTIVE = 4'd8;
               

    // Propuesta: Tres estados: IDLE, lectura, escritura.
    always @(posedge CLK) begin
    if (!RESET) begin  //RESET activo en bajo
        MDIO_DONE <= 0;
        MDIO_IN <= 0;
        ADDR <= 0;
        REGADR <=0;
        WR_DATA <= 0;
        WR_STB <= 0;
        counter <= 0;
        state <= IDLE;
        frame <= 0;
        end
    else begin
        state <= prox_state;
    end
    end 

//comunicacion usando el clk: mdc
always @(posedge mdc) begin     
    case (state)
        ACTIVE:begin 
            frame[31-counter] <= MDIO_OUT; //MSB
            counter <= counter+1;
        end

        READ: begin
            frame[31-counter] <= MDIO_OUT; // del cpu al generador
            counter <= counter+1;
             if ( counter>=0 && counter <= 16)
                if(MDIO_DONE && WR =0) // lo que envia el phy al receptor, y el receptor devuelve al gen por mdio_in
                MDIO_IN = RD_DATA;
        end 

        WRITE: begin // escritura en alto los primeros 16 bits
            frame[31-counter] <= MDIO_OUT; //MSB
            counter <= counter+1;
            if( counter >=4 && counter < 9 )
                ADDR = MDIO_OUT;
            if ( counter>=0 && counter <= 16)
                WR_DATA = MDIO_OUT;   
        end
    endcase
end

// logica de proximo estado y salidas
always @(*) begin
    //valor por defecto:
    prox_state = state;
    
    case (state)
        IDLE: begin
            if (MDIO_OE) begin
                prox_state = ACTIVE;
            end       
        end
        ACTIVE: begin
            if (frame [29:28] == 2'b10)begin
                prox_state = READ;
                end 
            else if (frame [29:28] == 2'b01) begin
                prox_state = WRITE;
            end 
        end

        WRITE: begin
        end

        READ: begin
        end
    endcase 
end 
endmodule