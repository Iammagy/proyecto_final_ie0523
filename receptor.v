module mdio_receptor (
    input wire MDC,
    input wire RESET,
    input wire MDIO_OUT,
    input wire MDIO_OE,
    input wire [15:0] RD_DATA,
    output reg MDIO_DONE,
    output reg MDIO_IN,
    output reg [4:0] ADDR,
    output reg [4:0] REGADR,
    output reg [15:0] WR_DATA,
    output reg WR_STB

);

    reg [3:0] state, prox_state;
     // registro interno que almacena los 32 bits del "frame" de la trans MDIO.
    reg [4:0] counter;            //debe contar de 0 hasta 31 (5bits)
    reg [15:0] mem [0:4];   // Memoria
    reg [1:0] tipo;
    
    localparam IDLE = 4'd1, // One hot
               WE = 4'd6,
               READ = 4'd2,
               WRITE = 4'd4,
               ACTIVE = 4'd8;


    // Propuesta: Tres estados: IDLE, lectura, escritura.
    always @(posedge MDC) begin
    if (!RESET) begin  //RESET activo en bajo
        MDIO_DONE <= 0;
        MDIO_IN <= 0;
        ADDR <= 0;
        REGADR <=0;
        WR_DATA <= 0;
        WR_STB <= 0;
        counter <= 0;
        state <= IDLE;
        end
    else begin
        state <= prox_state;
    end
    end 

//comunicacion usando el clk: mdc
always @(posedge MDC) begin     
    case (state)
        ACTIVE:begin 
            if( counter >=2 && counter < 4 ) begin
                tipo[3-counter]<=MDIO_OUT;
                $display(counter);
            end
            if( counter >=4 && counter < 9 )  begin
                ADDR[9-counter] <= MDIO_OUT;
            end
            counter <= counter+1;
        end

        READ: begin
            //frame[31-counter] <= MDIO_OUT; // del cpu al generador
            counter <= counter+1;
             if ( counter>=0 && counter <= 16) begin
                if(MDIO_DONE) begin// lo que envia el phy al receptor, y el receptor devuelve al gen por mdio_in
                MDIO_IN <= RD_DATA;
                end
             end
        end 

        WRITE: begin // escritura en alto los primeros 16 bits
            if (counter>=16) begin
            WR_DATA[31-counter] <= MDIO_OUT;
            end
            counter <= counter+1;
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
            if (tipo == 2'b10)begin
                prox_state = READ;
                end 
            else if (tipo == 2'b01 && counter>9) begin
                prox_state = WRITE;
            end 
            else if (counter == 32)begin
                 prox_state = IDLE;
            end
        end
        WRITE: begin
            if (counter == 32) begin
                state <= WE;
                MDIO_DONE<=1;
                WR_STB<=1;
            end
        end
        WE: begin
            mem[ADDR] <= WR_DATA;
            MDIO_DONE<=0;
            WR_STB<=0;
            prox_state=IDLE;
        end

        READ: begin
        end
    endcase 
end 
endmodule