module gn #(
        parameter DATA_WIDTH = 8,
        parameter IMG_WIDTH = 8,
        parameter IMG_HEIGHT = 8,
        parameter CHANNEL_NUM = 64,
        parameter CHANNEL_IN_GROUP = 16,
        parameter GROUP_NUM = CHANNEL_NUM / CHANNEL_IN_GROUP
    ) (
        input  wire                  clk,
        input  wire                  reset,
        input  wire                  end_of_frame,
        input  wire                  sd,
        input  wire                  mean,
        input  reg [DATA_WIDTH-1:0]  data_in,
        output reg [DATA_WIDTH-1:0]  data_out
    );

    reg [DATA_WIDTH - 1 : 0]group[IMG_WIDTH * IMG_HEIGHT : 0];

    always @(*) begin
        if (reset) begin
            data_out <= 0;
        end
        else begin
            data_out <= 1 / sd * (data_in - mean);
        end
    end

endmodule