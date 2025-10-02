// ============================================================================
// Plugin Image Processor para RS5 - Conversão RGB para Preto e Branco
// ============================================================================
// Este módulo implementa um acelerador de hardware para conversão de imagens
// coloridas para preto e branco usando computação aproximada.
//
// Algoritmo aproximado usado: Gray = (R + G + B) >> 2
// (divisão por 4 em vez da conversão padrão 0.299*R + 0.587*G + 0.114*B)
//
// Autor: João Carlos Brito Filho
// Data: 2024
// ============================================================================

module plugin_image_processor
    import RS5_pkg::*;
(
    // Clock e Reset
    input  logic        clk,
    input  logic        reset_n,
    
    // Interface de controle
    input  logic        start,          // Inicia operação
    output logic        busy,           // Ocupado processando
    output logic        done,           // Operação concluída
    
    // Parâmetros da imagem
    input  logic [31:0] in_start_addr,  // Endereço inicial da imagem RGB
    input  logic [31:0] in_end_addr,    // Endereço final da imagem RGB
    input  logic [31:0] out_start_addr, // Endereço inicial da imagem P&B
    input  logic [31:0] out_end_addr,   // Endereço final da imagem P&B
    input  logic [31:0] width,          // Largura da imagem
    input  logic [31:0] height,         // Altura da imagem
    output logic [31:0] progress,       // Contador de progresso
    
    // Interface de memória
    output logic        mem_req,        // Requisição de memória
    output logic        mem_we,         // Write enable
    output logic [31:0] mem_addr,       // Endereço de memória
    output logic [31:0] mem_wdata,      // Dados para escrita
    input  logic [31:0] mem_rdata,      // Dados lidos da memória
    input  logic        mem_ready       // Memória pronta
);

    // FSM states
    typedef enum logic [2:0] {
        IDLE         = 3'b000,  // Aguardando operação
        SETUP        = 3'b001,  // Configuração inicial
        READ_PIXEL   = 3'b010,  // Lendo pixel RGB
        CONVERT      = 3'b011,  // Convertendo para P&B
        WRITE_PIXEL  = 3'b100,  // Escrevendo pixel P&B
        NEXT_PIXEL   = 3'b101,  // Avançar para próximo pixel
        FINISH       = 3'b110   // Operação finalizada
    } img_state_t;

    // Registradores internos
    img_state_t state, next_state;
    
    // Configuração da operação
    logic [31:0] in_start_reg, in_end_reg;
    logic [31:0] out_start_reg, out_end_reg;
    logic [31:0] width_reg, height_reg;
    
    // Controle de processamento
    logic [31:0] current_pixel;        // Índice do pixel atual (0 a width*height-1)
    logic [31:0] total_pixels;         // Total de pixels na imagem
    logic [31:0] current_in_addr;      // Endereço atual de leitura
    logic [31:0] current_out_addr;     // Endereço atual de escrita
    
    // Dados do pixel
    logic [31:0] rgb_data;             // Dados RGB lidos da memória
    logic [7:0]  red, green, blue;     // Componentes RGB extraídos
    logic [7:0]  gray_value;           // Valor em escala de cinza
    logic [31:0] gray_data;            // Dados P&B para escrita
    
    // Flags de controle
    logic busy_reg, done_reg;
    logic mem_req_reg;
    logic mem_we_reg;
    logic [31:0] mem_addr_reg;
    logic [31:0] mem_wdata_reg;

    // Cálculo de endereços
    // Assumindo que cada pixel RGB ocupa 4 bytes (32 bits): 0xRRGGBB00
    // E cada pixel P&B ocupa 1 byte, mas vamos usar 4 bytes por alinhamento
    always_comb begin
        current_in_addr  = in_start_reg + (current_pixel << 2);   // *4 bytes por pixel
        current_out_addr = out_start_reg + (current_pixel << 2);  // *4 bytes por pixel
        total_pixels     = width_reg * height_reg;
    end

    // Extração de componentes RGB do dado de 32 bits
    // Formato assumido: 0xRRGGBB00 (Red nos bits [31:24], Green nos [23:16], Blue nos [15:8])
    assign red   = rgb_data[31:24];
    assign green = rgb_data[23:16];
    assign blue  = rgb_data[15:8];

    // Conversão aproximada para escala de cinza: (R + G + B) / 4
    // Isso é uma aproximação computacionalmente simples
    logic [9:0] sum_rgb;  // Soma de R+G+B (máximo 765, precisa 10 bits)
    assign sum_rgb = {2'b00, red} + {2'b00, green} + {2'b00, blue};
    assign gray_value = sum_rgb[9:2];  // Divisão por 4 (shift right 2)

    // Preparação do dado de saída (repetir gray_value em todos os canais)
    assign gray_data = {gray_value, gray_value, gray_value, 8'h00};

    // Máquina de estados - lógica de próximo estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = SETUP;
            end
            SETUP: begin
                next_state = READ_PIXEL;
            end
            READ_PIXEL: begin
                if (mem_ready) next_state = CONVERT;
            end
            CONVERT: begin
                next_state = WRITE_PIXEL;
            end
            WRITE_PIXEL: begin
                if (mem_ready) next_state = NEXT_PIXEL;
            end
            NEXT_PIXEL: begin
                if (current_pixel >= total_pixels - 1) begin
                    next_state = FINISH;
                end else begin
                    next_state = READ_PIXEL;
                end
            end
            FINISH: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Registrador de estado
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Datapath - lógica principal do processamento
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset de todos os registradores
            in_start_reg     <= 32'b0;
            in_end_reg       <= 32'b0;
            out_start_reg    <= 32'b0;
            out_end_reg      <= 32'b0;
            width_reg        <= 32'b0;
            height_reg       <= 32'b0;
            current_pixel    <= 32'b0;
            rgb_data         <= 32'b0;
            busy_reg         <= 1'b0;
            done_reg         <= 1'b0;
            mem_req_reg      <= 1'b0;
            mem_we_reg       <= 1'b0;
            mem_addr_reg     <= 32'b0;
            mem_wdata_reg    <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy_reg      <= 1'b0;
                    done_reg      <= 1'b0;
                    mem_req_reg   <= 1'b0;
                    mem_we_reg    <= 1'b0;
                    current_pixel <= 32'b0;
                    
                    if (start) begin
                        // Capturar parâmetros da operação
                        in_start_reg  <= in_start_addr;
                        in_end_reg    <= in_end_addr;
                        out_start_reg <= out_start_addr;
                        out_end_reg   <= out_end_addr;
                        width_reg     <= width;
                        height_reg    <= height;
                        busy_reg      <= 1'b1;
                    end
                end
                
                SETUP: begin
                    busy_reg      <= 1'b1;
                    done_reg      <= 1'b0;
                    current_pixel <= 32'b0;
                end
                
                READ_PIXEL: begin
                    busy_reg    <= 1'b1;
                    done_reg    <= 1'b0;
                    mem_req_reg <= 1'b1;
                    mem_we_reg  <= 1'b0;
                    mem_addr_reg <= current_in_addr;
                    
                    if (mem_ready) begin
                        rgb_data <= mem_rdata;
                        mem_req_reg <= 1'b0;
                    end
                end
                
                CONVERT: begin
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                    // Conversão feita combinacionalmente
                    // gray_value já calculado
                end
                
                WRITE_PIXEL: begin
                    busy_reg      <= 1'b1;
                    done_reg      <= 1'b0;
                    mem_req_reg   <= 1'b1;
                    mem_we_reg    <= 1'b1;
                    mem_addr_reg  <= current_out_addr;
                    mem_wdata_reg <= gray_data;
                    
                    if (mem_ready) begin
                        mem_req_reg <= 1'b0;
                        mem_we_reg  <= 1'b0;
                    end
                end
                
                NEXT_PIXEL: begin
                    busy_reg <= 1'b1;
                    done_reg <= 1'b0;
                    current_pixel <= current_pixel + 1;
                end
                
                FINISH: begin
                    busy_reg <= 1'b0;
                    done_reg  <= 1'b1;
                    mem_req_reg <= 1'b0;
                    mem_we_reg  <= 1'b0;
                end
                
                default: begin
                    busy_reg <= 1'b0;
                    done_reg <= 1'b0;
                    mem_req_reg <= 1'b0;
                    mem_we_reg  <= 1'b0;
                end
            endcase
        end
    end

    // Saídas
    assign busy     = busy_reg;
    assign done     = done_reg;
    assign progress = current_pixel;
    assign mem_req  = mem_req_reg;
    assign mem_we   = mem_we_reg;
    assign mem_addr = mem_addr_reg;
    assign mem_wdata = mem_wdata_reg;

endmodule