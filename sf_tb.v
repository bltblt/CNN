module sf_tb();

reg clock;
reg reset;
reg  [7:0] data_in;
wire [7:0] data_out;
reg [10:0] i;
localparam CLK_PERIOD = 10;

shiftRegister shiftRegister_inst(
    .clock(clock),
    .data_in(data_in),
    .data_out(data_out),
    .reset(reset)
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
    for(i=0; i<63; i=i+1)begin
        #0 @(posedge clock)
        data_in= i;
    end
    #(CLK_PERIOD*20);
    $stop;
end

endmodule