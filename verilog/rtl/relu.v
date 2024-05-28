module ReLU (
    input wire clk,
    input wire reset,
    input wire [63:0] data_in,
    output reg [63:0] data_out,
    input wire start,
    output reg done
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 64'b0;
            done <= 1'b0;
        end else if (start) begin
            // ReLU logic
            data_out <= (data_in[63] == 1'b0) ? data_in : 64'b0;
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end
endmodule