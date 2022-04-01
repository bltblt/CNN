module kernal #(
        parameter DATA_WIDTH = 8,
        parameter IMG_WIDTH = 8,
        parameter IMG_HEIGHT = 8,
        parameter FILTER_WIDTH = 4,
        parameter FILTER_HEIGHT = 4
    ) (
        input  wire                  clock,
        input  wire                  reset,
        input  reg [DATA_WIDTH-1:0]  inpixel,
        input  reg [DATA_WIDTH-1:0]  weight_in,
        output reg [DATA_WIDTH-1:0]  dout
    );

    reg [DATA_WIDTH-1:0] outpixel;//output pixel
    reg [DATA_WIDTH-1:0] g;//value of every dot multiplication
    reg [DATA_WIDTH-1:0]sr[(FILTER_WIDTH-1)*IMG_WIDTH+(FILTER_WIDTH-1):0];//shift register to store the input

    reg [$clog2(IMG_WIDTH*IMG_HEIGHT)-1 : 0] cnt_inpixel;//count the num of input
    wire [$clog2(IMG_WIDTH*IMG_HEIGHT)-1 : 0] cnt_outpixel;//count the num of output

    reg [$clog2(IMG_HEIGHT)-1 : 0] cnt_col;// which col
    reg [$clog2(IMG_WIDTH)-1 : 0] cnt_row;// which row

    reg [DATA_WIDTH-1:0]sliding[FILTER_WIDTH-1:0][FILTER_HEIGHT-1:0];//filter window
    reg [DATA_WIDTH-1:0]filter[FILTER_WIDTH*FILTER_HEIGHT-1:0];//store filter matrix

    reg first_row_enable;
    reg row_enable;
    reg last_row_enable;
    reg edge_enable;
    reg enable;
    wire weight_in_en;

    integer i, j;

    assign cnt_outpixel = cnt_row * IMG_WIDTH + cnt_col;

    always @(posedge clock) begin
        if (reset == 1'b1) begin
            outpixel <= 0;
            cnt_inpixel <= 0;
            for( i = 0; i < (FILTER_WIDTH-1)*IMG_WIDTH + (FILTER_WIDTH-1); i = i + 1)
                sr[i] <= 0;
        end else begin
            outpixel <= sr[2*IMG_WIDTH + 2];
            sr[0] <= inpixel;
            for( i = 1; i < (FILTER_WIDTH-1)*IMG_WIDTH+FILTER_WIDTH; i = i + 1)
                sr[i] <= sr[i-1];
            if(cnt_inpixel < (IMG_WIDTH * IMG_HEIGHT))begin
                cnt_inpixel <= cnt_inpixel + 1;
            end
            else if(cnt_inpixel == (IMG_WIDTH * IMG_HEIGHT))begin
                cnt_inpixel <= '0;
            end
            else begin
                cnt_inpixel <= cnt_inpixel;
            end
        end
    end
        
    always @(posedge clock) begin//load weight
        if (reset == 1'b1) begin
            for( j = 0; j <= (FILTER_WIDTH*FILTER_HEIGHT-1); j = j + 1)
                sr[i] <= 0;
        end else begin
            for (j = 0; j <= FILTER_WIDTH*FILTER_HEIGHT-1; j = j + 1) begin
                filter[j] <= weight_in;
            end
        end
    end

    always @(*) begin//according to the size of the filter
            sliding[0][0] = sr[3 * IMG_WIDTH + 3];
            sliding[0][1] = sr[3 * IMG_WIDTH + 2];
            sliding[0][2] = sr[3 * IMG_WIDTH + 1];
            sliding[0][3] = sr[3 * IMG_WIDTH];
            sliding[1][0] = sr[2 * IMG_WIDTH + 3];
            sliding[1][1] = sr[2 * IMG_WIDTH + 2];
            sliding[1][2] = sr[2 * IMG_WIDTH + 1];
            sliding[1][3] = sr[2 * IMG_WIDTH];
            sliding[2][0] = sr[IMG_WIDTH + 3];
            sliding[2][1] = sr[IMG_WIDTH + 2];
            sliding[2][2] = sr[IMG_WIDTH + 1];
            sliding[2][3] = sr[IMG_WIDTH];
            sliding[3][0] = sr[3];
            sliding[3][1] = sr[2];
            sliding[3][2] = sr[1];
            sliding[3][3] = sr[0];
        end

    reg [DATA_WIDTH + 1 : 0] g11, g12, g13, g14, g21, g22, g23, g24, g31, g32, g33, g34, g41, g42, g43, g44;

    always @(*) begin
        g11 <= sliding[0][0] * filter[0];
        g12 <= sliding[0][1] * filter[1];
        g13 <= sliding[0][2] * filter[2];
        g14 <= sliding[0][3] * filter[3];
        g21 <= sliding[1][0] * filter[4];
        g22 <= sliding[1][1] * filter[5];
        g23 <= sliding[1][2] * filter[6];
        g24 <= sliding[1][3] * filter[7];
        g31 <= sliding[2][0] * filter[8];
        g32 <= sliding[2][1] * filter[9];
        g33 <= sliding[2][2] * filter[10];
        g34 <= sliding[2][3] * filter[11];
        g41 <= sliding[3][0] * filter[12];
        g42 <= sliding[3][1] * filter[13];
        g43 <= sliding[3][2] * filter[14];
        g44 <= sliding[3][3] * filter[15];
    end

    reg [DATA_WIDTH + 2 : 0] g_normal;

    always @(*) begin
        g_normal = g11 + g12 + g13 + g14 + g21 + g22 + g23 + g24 + g31 + g32 + g33 + g34 + g41 + g42 + g43 + g44;
        g = (g_normal > 255) ? 255 : g_normal[DATA_WIDTH - 1 : 0]; 
    end

    always @(*) begin
        if (cnt_outpixel < IMG_WIDTH + 1) begin
            first_row_enable <= 1'b1;
        end else begin
            first_row_enable <= 1'b0;
        end
    end

    always @(posedge clock)begin
        if (reset) begin
            cnt_col <= 1'b0;
            cnt_row <= 1'b0;
        end 
        else if (cnt_col == IMG_WIDTH - 1'b1) begin
            cnt_col <= 1'b0;
            cnt_row <= cnt_row + 1'b1;
        end     
        else begin
            cnt_col <= cnt_col + 1'b1;
        end
    end

    reg data_valid;

    always@(posedge clock or posedge reset)begin
        if(reset)begin
            data_valid <= '0; 
        end   
        else begin
            if(cnt_inpixel >= IMG_WIDTH * 3 + 3)begin
                data_valid <= '1;
            end
            else begin
                data_valid <= '0;
            end
        end
    end

    always @(*) begin
        if (cnt_inpixel % IMG_WIDTH >= 1 & cnt_inpixel % IMG_WIDTH <= IMG_WIDTH - 2 & cnt_inpixel >= IMG_WIDTH + 1) begin
            row_enable = 1'b1;
        end
        else begin
            row_enable = 1'b0;
        end
    end


    always @(*) begin
        if (cnt_outpixel >= IMG_WIDTH * (IMG_HEIGHT - 1) - 1) begin
            last_row_enable = 1'b1;
        end else begin
            last_row_enable = 1'b0;
        end
    end

    always @(*) begin
        if(
            (cnt_outpixel >= IMG_WIDTH + 1) &
            (cnt_outpixel < IMG_WIDTH * (IMG_HEIGHT - 1) - 1) &
            (((cnt_col + 1) == IMG_WIDTH) | (cnt_col == 0))
        )begin
            edge_enable = 1'b1;
        end
        else begin
            edge_enable = 1'b0;
        end
    end

    always @(*) begin
        if(last_row_enable | first_row_enable | edge_enable)begin
            dout = '0;
        end
        else begin
            dout = g;
        end
    end


endmodule

