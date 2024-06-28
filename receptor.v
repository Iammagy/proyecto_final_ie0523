module mdio_receptor (
    input wire MDC,
    input wire RESET,
    input wire MDIO_OUT,
    input wire MDIO_OE,
    output reg MDIO_DONE,
    output reg MDIO_IN,
    output reg [4:0] ADDR,
    output reg [15:0] WR_DATA,
    output reg WR_STB

);
    reg [15:0] RD_DATA;
    reg [3:0] state;
    reg [5:0] counter;      //debe contar de 0 hasta 31 (5bits)
    reg [15:0] mem [0:31];   // Memoria
    reg [1:0] tipo;
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            mem[i] = 16'b0;
            if (i==3) begin   //En la posición 3 de memoria almacenamos AAAA
                mem[i] = 16'h2AAA;
            end
        end
    end

    localparam IDLE = 4'd1, // One hot
               READ = 4'd2,
               WRITE = 4'd4,
               ACTIVE = 4'd8;


    always @(posedge MDC or negedge RESET) begin
    if (!RESET) begin  //RESET activo en bajo
        MDIO_DONE <= 0;
        MDIO_IN <= 0;
        ADDR <= 0;
        WR_DATA <= 0;
        WR_STB <= 0;
        counter <= 0;
        state <= IDLE;

        end else begin
        case (state)
            ACTIVE: begin 
                if( counter >=2 && counter < 4 ) begin
                    tipo[3-counter]<=MDIO_OUT;
                end
                if( counter >=4 && counter < 9 )  begin
                    ADDR[8-counter] <= MDIO_OUT;
                end
                if (counter>=16 && tipo == 2'b01) begin
                    WR_DATA[31-counter] <= MDIO_OUT;
                end
                if (counter>=16 && tipo == 2'b10) begin
                    RD_DATA <= mem[ADDR];
                end
                counter <= counter+1;
            end

            READ: begin
                MDIO_IN <= RD_DATA[31-counter];
                counter <= counter+1;
            end 

        endcase
        end
    end 

// logica de proximo estado
always @(posedge MDC) begin
    case (state)
        IDLE: begin
            MDIO_DONE = 0;
            MDIO_IN = 0;
            ADDR = 0;
            WR_DATA = 0;
            WR_STB = 0;
            counter = 0;
            tipo=0;

            if (MDIO_OE) begin
                state = ACTIVE;
            end
            else begin
                state = IDLE;
            end   
        end

        ACTIVE: begin
            if (tipo == 2'b10 && counter>=16) begin
                state = READ;
                end 
            if (tipo == 2'b01 && counter>=32) begin
                WR_STB = 1;
                state = WRITE;
            end 
            else if (counter>=32) begin
                state = IDLE;
            end
        end
        
        WRITE: begin
            MDIO_DONE = 1;
            mem[ADDR] = WR_DATA;
            state = IDLE;
        end

        READ: begin
            if (counter>=31) begin
            MDIO_DONE = 1;
            state = IDLE;
            end
        end

    endcase 
end 

endmodule
