`timescale 1ns/1ns

module kernal_tb ();
reg clock;
reg reset;
reg [7:0] inpixel;
wire [7:0] dout;
reg [10:0] i;
reg [7:0]weight_in;
localparam CLK_PERIOD = 10;

kernal kernal_inst(
    .clock(clock),
    .inpixel(inpixel),
    .dout(dout),
    .reset(reset),
    .weight_in(weight_in)
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
    inpixel = 0;
    weight_in = 0;
    for(i=0; i<=63; i=i+1)begin
        #0 @(posedge clock)
        inpixel= i;
        weight_in = i + 1;
    end
end



/*
    Here, din will return 0 after 0-479, and return from 0-479 again;
    Therefore, each row of data is simulated from 0 to 479, so when the three rows of data are aligned during simulation, their data will be the same.

    If the input din is the real image data, because each row of the image data in a frame is different, the data of the three rows after alignment is also different.
*/
// always @ (posedge clock)begin
//     if(reset)
//         inputpixel <= 0;
//     else if(inputpixel == 36)
//         inputpixel <= 0;
//     else if (valid_in == 1'b1)
//         inputpixel <= inputpixel + 1'b1;
// end



endmodule