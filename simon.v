module simon(
    input wire clk,
    input wire rst,
    input wire [3:0] btn,     
    input wire start,
    input wire difficulty, // 1 = Slow, 0 = Fast         
    output reg [3:0] led,     
    output reg [11:0] rgb,    
    output reg hsync,         
    output reg vsync,         
    output reg [6:0] score,   // 7-segment display segments
    output reg [3:0] an       // Anode control for digit selection
);

    // VGA parameters
    parameter H_DISPLAY = 640;
    parameter H_FRONT = 16;
    parameter H_SYNC = 96;
    parameter H_BACK = 48;
    parameter V_DISPLAY = 480;
    parameter V_FRONT = 10;
    parameter V_SYNC = 2;
    parameter V_BACK = 33;
    
    parameter TOTAL_COLS = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
    parameter TOTAL_ROWS = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;
    
    //difficuly parameters
    parameter SLOW_DELAY_ON = 27'd50000000;
    parameter SLOW_DELAY_OFF = 27'd60000000;
    parameter FAST_DELAY_ON = 27'd20000000;
    parameter FAST_DELAY_OFF = 27'd25000000;

    // Game states
    localparam IDLE = 3'b000;
    localparam SHOW = 3'b001;
    localparam WAIT = 3'b010;
    localparam INPUT = 3'b011;
    localparam WIN = 3'b100;
    localparam LOSE = 3'b101;

    // Internal registers
    reg [2:0] state;
    reg [3:0] sequence [15:0];
    reg [4:0] current_length;
    reg [4:0] current_pos;
    reg [26:0] counter;
    reg [9:0] h_count;
    reg [9:0] v_count;
    reg [3:0] btn_prev;
    reg [3:0] btn_valid;
    reg pixel_clk;
    reg [1:0] clk_div;
    reg [26:0] delay_counter; // Counter for delay (adjust bit-width as needed)
    
    // Display registers
    reg [16:0] refresh_counter;
    wire [1:0] display_select;
    reg [3:0] digit_value;  // Current score value (0-15)
    
    assign display_select = refresh_counter[16:15];

    // Initialize
    initial begin
        state = IDLE;
        current_length = 0;
        current_pos = 0;
        digit_value = 0;
        btn_prev = 0;
        btn_valid = 0;
        refresh_counter = 0;
    end

    // Clock divider for VGA
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
        pixel_clk <= (clk_div == 0);
        refresh_counter <= refresh_counter + 1;
    end

    // Button edge detection
    always @(posedge clk) begin
        btn_prev <= btn;
        btn_valid <= (btn & ~btn_prev);
    end

    // VGA timing
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == TOTAL_COLS - 1) begin
                h_count <= 0;
                if (v_count == TOTAL_ROWS - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else
                h_count <= h_count + 1;
        end
    end

    // Sync signals
    always @* begin
        hsync = ~((h_count >= (H_DISPLAY + H_FRONT)) && 
                  (h_count < (H_DISPLAY + H_FRONT + H_SYNC)));
        vsync = ~((v_count >= (V_DISPLAY + V_FRONT)) && 
                  (v_count < (V_DISPLAY + V_FRONT + V_SYNC)));
    end

    // Seven-segment display control
    always @* begin
        case(display_select)
            2'b00: begin
                an = 4'b1110;  // Rightmost digit
                case(digit_value)
                    4'h0: score = 7'b1000000; // 0
                    4'h1: score = 7'b1111001; // 1
                    4'h2: score = 7'b0100100; // 2
                    4'h3: score = 7'b0110000; // 3
                    4'h4: score = 7'b0011001; // 4
                    4'h5: score = 7'b0010010; // 5
                    4'h6: score = 7'b0000010; // 6
                    4'h7: score = 7'b1111000; // 7
                    4'h8: score = 7'b0000000; // 8
                    4'h9: score = 7'b0010000; // 9
                    default: score = 7'b1111111; // Off
                endcase
            end
            default: begin
                an = 4'b1111;  // All other digits off
                score = 7'b1111111; // All segments off
            end
        endcase
    end

    // Random sequence generator
    reg [15:0] lfsr;
    always @(posedge clk) begin
        if (rst)
            lfsr <= 16'hFFFF;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3]};
    end

    // Main game logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            current_length <= 0;
            current_pos <= 0;
            digit_value <= 0;
            led <= 4'b0000;
            counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    led <= 4'b0000;
                    if (start) begin
                        state <= SHOW;
                        //sequence[0] <= (lfsr[1:0] == 2'b11) ? 2'b10 : {1'b0, lfsr[0]};
                        sequence[0] <= lfsr[1:0];
                        current_length <= 1;
                        current_pos <= 0;
                        counter <= 0;
                        digit_value <= 0;
                    end
                end

                SHOW: begin
                    if (difficulty) begin
                        // Slow mode
                        if (delay_counter < SLOW_DELAY_ON) begin
                            led <= (4'b0001 << sequence[current_pos]); // Display current LED
                            delay_counter <= delay_counter + 1;
                        end else if (delay_counter < SLOW_DELAY_OFF) begin
                            led <= 4'b0000; // Turn off LED
                            delay_counter <= delay_counter + 1;
                        end else begin
                            delay_counter <= 0;
                            if (current_pos == current_length - 1) begin
                                state <= INPUT;
                                current_pos <= 0;
                                led <= 4'b0000;
                            end else begin
                                current_pos <= current_pos + 1;
                            end
                        end
                    end else begin
                        // Fast mode
                        if (delay_counter < FAST_DELAY_ON) begin
                            led <= (4'b0001 << sequence[current_pos]); // Display current LED
                            delay_counter <= delay_counter + 1;
                        end else if (delay_counter < FAST_DELAY_OFF) begin
                            led <= 4'b0000; // Turn off LED
                            delay_counter <= delay_counter + 1;
                        end else begin
                            delay_counter <= 0;
                            if (current_pos == current_length - 1) begin
                                state <= INPUT;
                                current_pos <= 0;
                                led <= 4'b0000;
                            end else begin
                                current_pos <= current_pos + 1;
                            end
                        end
                    end
                end


                INPUT: begin
                    led <= btn;
                    if (|btn_valid) begin
                        if (btn_valid == (4'b0001 << sequence[current_pos])) begin
                            if (current_pos == current_length - 1) begin
                                if ((difficulty && current_length == 5) || (!difficulty && current_length == 4)) begin
                                    digit_value <= digit_value + 1;
                                    state <= WIN;
                                end else begin
                                    state <= SHOW;
                                    sequence[current_length] <= (lfsr[1:0] == 2'b11) ? 2'b10 : {1'b0, lfsr[0]};
                                    current_length <= current_length + 1;
                                    current_pos <= 0;
                                    if (digit_value < 9) // Limit score to 9
                                        digit_value <= digit_value + 1;
                                    counter <= 0;
                                end
                            end else begin
                                current_pos <= current_pos + 1;
                            end
                        end else begin
                            state <= LOSE;
                        end
                    end
                end


                WIN: begin
                    led <= 4'b1111;
                    if (start) begin
                        state <= IDLE;
                    end
                end

                LOSE: begin
                    led <= 4'b0000;
                    counter <= counter + 1;
                    if (start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // VGA color output
    always @* begin
        if (h_count < H_DISPLAY && v_count < V_DISPLAY) begin
            case (state)
                IDLE: rgb = 12'h333;
                SHOW, INPUT: begin
                    case (led)
                        4'b0001: rgb = 12'h00F;//red
                        4'b0010: rgb = 12'hFF0;//turkuaz
    
                        4'b0100: rgb = 12'hF0F;//yellow
                        4'b1000: rgb = 12'h0F0;//blue
                        default: rgb = 12'h444;
                    endcase
                end
                WIN: rgb = 12'hF00;
                LOSE: rgb = (counter[24]) ? 12'h00F : 12'h333;
                default: rgb = 12'h333;
            endcase
        end else
            rgb = 12'h000;
    end

endmodule