module shiftRegister(
    input wire clock,
    input wire reset,
    input reg  [7:0]data_in,
    output reg [7:0]data_out
);

reg [7:0]sr[27:0];//shift register to store the input
integer i;

always @(posedge clock) begin
    if (reset == 1'b1) begin
        for( i = 0;i < 27; i=i+1)
            sr[i] <= 0;
    end else begin
        data_out <= sr[27];
        sr[0] <= data_in;
        for(i=1;i<28;i=i+1)
            sr[i] <= sr[i-1];
    end
end

endmodule
