module PE (
    input wire clk,
    input wire reset,
    input wire [15:0] ifmap,
    input wire [63:0] filt,
    input wire [63:0] input_psum,
    output reg [63:0] output_psum,
    input wire start,
    output reg done
);

    reg [15:0] ifmap_scratchpad [0:11];
    reg [63:0] filter_scratchpad [0:223];
    reg [15:0] psum_scratchpad [0:23];
    reg [15:0] zero_buffer;

    wire [15:0] ifmap_data;
    wire [63:0] filter_data;
    wire [15:0] partial_sum_data;

    reg [31:0] mul_result_stage1;
    reg [63:0] mul_result_stage2;
    reg [63:0] accum_psum;
    reg [63:0] next_accum_psum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            zero_buffer <= 16'b0;
            accum_psum <= 64'b0;
            done <= 1'b0;
        end else if (start) begin
            ifmap_scratchpad[0] <= ifmap;
            filter_scratchpad[0] <= filt;
            psum_scratchpad[0] <= input_psum[15:0];
            accum_psum <= next_accum_psum;
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

    // Two-stage pipelined multiplier
    always @(posedge clk) begin
        mul_result_stage1 <= ifmap * filt[15:0];
        mul_result_stage2 <= {16'b0, mul_result_stage1}; // Actual multiplication logic
    end

    // Accumulate partial sums
    always @* begin
        next_accum_psum = accum_psum + mul_result_stage2;
        output_psum = next_accum_psum;
    end
endmodule