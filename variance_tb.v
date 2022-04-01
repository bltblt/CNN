module variance_tb ();

reg clock;
reg reset;
reg [7:0] data_in;
wire [15:0] variance;
reg [10:0] i;
reg data_valid;
wire [7:0] mean;
localparam WIDTH = 8;
localparam IMG_WIDTH = 8;
localparam IMG_HEIGHT = 8;
localparam INPUT_NUM = IMG_WIDTH * IMG_HEIGHT;
localparam CLK_PERIOD = 10;

variance #(
    .WIDTH(WIDTH),
    .IMG_WIDTH(IMG_WIDTH),
    .IMG_HEIGHT(IMG_HEIGHT),
    .INPUT_NUM(INPUT_NUM)
) variance_inst(
    .clk(clock),
    .reset(reset),
    .data_in(data_in),
    .variance(variance),
    .data_valid(data_valid),
    .mean(mean)
);

always begin
    clock = 1'b1;
    #(CLK_PERIOD/2);
    clock = 1'b0;
    #(CLK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin
    @(negedge reset);
    data_in = 0;
    data_valid = 0;
    for(i=0; i<=9; i=i+1)begin
        #0 @(posedge clock)
        data_in= data_in + 1;
        if ( i == 9 ) begin
            data_valid = 1;
        end
        else data_valid = 0;
    end
end

endmodule