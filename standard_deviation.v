module sd #(
		parameter WIDTH = 8, // data input width
        parameter FBITS = 0
	) (
        input wire [WIDTH-1:0] variance_in,
        output reg [WIDTH-1:0] sd_out,
        // input wire reset,
        input wire clk
    );

    wire start;
    wire busy;
    wire valid;
    reg [WIDTH-1:0] rem;

    sqrt #(
        .WIDTH(WIDTH),  // width of radicand
        .FBITS(FBITS)   // fractional bits (for fixed point)
    ) sqrt_inst (
        .clk(clk),
        .start(start),             // start signal
        .busy(busy),               // calculation in progress
        .valid(valid),             // root and rem are valid
        .rad(variance_in),         // radicand
        .root(sd_out),             // root
        .rem(rem)                  // remainder
    );

endmodule