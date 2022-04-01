// `define WINDOW_SIZE ((2**WINDOW_WIDTH))
// `define MAXIMUM_ROLLING_SUM ((2**WIDTH)-1)
// `define MAXIMUM_ROLLING_SQUARES_SUM  ((2**WIDTH)-1)

module variance #(
		parameter WIDTH = 8, // data input width
		parameter IMG_WIDTH  = 8, 
		parameter IMG_HEIGHT = 8,
		parameter INPUT_NUM = IMG_WIDTH * IMG_HEIGHT
	) (
        input wire [WIDTH-1:0] data_in,
        output reg [WIDTH*2-1:0] variance,
		output reg [WIDTH-1:0] mean,
        input wire reset,
        input wire clk,
		input wire data_valid
    );

    reg [$clog2(2**WIDTH*IMG_WIDTH*IMG_HEIGHT)-1:0] rolling_sum;
    reg [$clog2(2**(2*WIDTH)*IMG_WIDTH*IMG_HEIGHT)-1:0] rolling_squares_sum;

    // wire [WIDTH-1:0] fifo_dout;
    // fifo #(
	// 	.WIDTH(WIDTH), 
	// 	.DEPTH(IMG_WIDTH*IMG_HEIGHT)
	// ) fifo_inst (
    // 	.data_in(data_in),
    // 	.data_out(fifo_dout),
    // 	.data_valid(fifo_data_valid),
    // 	.reset(reset),
    // 	.clk(clk)
    // );

    reg [$clog2(2**WIDTH*IMG_WIDTH*IMG_HEIGHT) - 1:0] mean_squared;
    reg [$clog2(2**(2*WIDTH)*IMG_WIDTH*IMG_HEIGHT) - 1:0] mean_of_squares;

    // reg [WIDTH-1:0] data_in_delay [2:0];
    // reg [WIDTH-1:0] fifo_dout_delay [2:0];
    reg [$clog2(2**(2*WIDTH))-1:0] data_in_squared;
    // reg [$clog2(2**(2*WIDTH))-1:0] fifo_dout_squared;
	reg [4:0] a;

    always @(posedge clk) begin
    	if (reset == 1'b1) begin
    		rolling_sum <= 0;
    		rolling_squares_sum <= 0;
			mean_squared <= 0;
			mean_of_squares <= 0;
			data_in_squared <= 0;
			variance  <= 0;		 
			mean <= 0;
    		// data_in_delay[0]     <= 0; data_in_delay[1]     <= 0; data_in_delay[2]     <= 0;
    		// data_in_squared[0]   <= 0; data_in_squared[1]   <= 0; data_in_squared[2]   <= 0;
    		// fifo_dout_delay[0]   <= 0; fifo_dout_delay[1]   <= 0; fifo_dout_delay[2]   <= 0;
    		// fifo_dout_squared[0] <= 0; fifo_dout_squared[1] <= 0; fifo_dout_squared[2] <= 0;

    	end else begin
    		// data_in_delay[0] <= data_in;
			// data_in_delay[1] <= data_in_delay[0];
			// data_in_delay[2] <= data_in_delay[1]; // delay is required to keep data in sync with DSP output

			// data_in_squared <= data_in*data_in;
			// data_in_squared[1] <= data_in_squared[0];
			// data_in_squared[2] <= data_in_squared[1]; // pipeline DSP output

    		if (data_valid) begin 
    			mean <= rolling_sum / 10;
				mean_squared <= (rolling_sum * rolling_sum) / 100;
    			mean_of_squares <= (rolling_squares_sum / 10);
    			variance <= mean_of_squares - mean_squared;
    		end else begin
    			// just load up the sums
    			rolling_sum <= rolling_sum + data_in;
    			rolling_squares_sum <= rolling_squares_sum + data_in*data_in;
    		end
    	end
    end


endmodule