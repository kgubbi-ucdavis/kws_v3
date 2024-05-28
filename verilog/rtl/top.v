module kws_v3 (
    input wire clk,
    input wire reset,
    input wire serial_data_in,
    input wire serial_load_enable,
    input wire start_computation,
    output wire serial_data_out,
    output reg computation_done
);

    // Internal signals
    reg [63:0] dram_data;
    reg [63:0] serial_shift_reg;
    reg [5:0] bit_counter;

    reg gb_write_enable;
    reg [63:0] gb_data_in;
    wire [63:0] gb_data_out;
    
    reg pe_start;
    wire [15:0] pe_done; // Changed to a bus for each PE's done signal
    wire [63:0] pe_output_psum[0:3][0:3];

    reg relu_start;
    wire relu_done;
    wire [63:0] relu_data_out;
    
    reg [63:0] aggregated_psum;
    reg [63:0] result;
    reg [5:0] result_bit_counter;
    reg result_serial_shift_enable;

    // Shift register to load data serially
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            serial_shift_reg <= 64'b0;
            bit_counter <= 6'b0;
        end else if (serial_load_enable) begin
            serial_shift_reg <= {serial_shift_reg[62:0], serial_data_in};
            bit_counter <= bit_counter + 1;
            if (bit_counter == 63) begin
                dram_data <= serial_shift_reg;
            end
        end
    end

    // Global Buffer
    GlobalBuffer global_buffer (
        .clk(clk),
        .reset(reset),
        .data_in(dram_data),
        .data_out(gb_data_out),
        .write_enable(gb_write_enable)
    );

    // ReLU Module
    ReLU relu (
        .clk(clk),
        .reset(reset),
        .data_in(gb_data_out),
        .data_out(relu_data_out),
        .start(relu_start),
        .done(relu_done)
    );

    // Instantiate 4x4 PE array
    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : PE_ROW
            for (j = 0; j < 4; j = j + 1) begin : PE_COL
                PE pe (
                    .clk(clk),
                    .reset(reset),
                    .ifmap(gb_data_out[15:0]),
                    .filt(gb_data_out[31:0]),
                    .input_psum(gb_data_out),
                    .output_psum(pe_output_psum[i][j]),
                    .start(pe_start),
                    .done(pe_done[i*4+j]) // Assign each done signal to a different bit
                );
            end
        end
    endgenerate

    // Aggregation logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            aggregated_psum <= 64'b0;
        end else begin
            aggregated_psum <= 64'b0; // Reset aggregation sum each cycle
            for (integer i = 0; i < 4; i = i + 1) begin
                for (integer j = 0; j < 4; j = j + 1) begin
                    aggregated_psum <= aggregated_psum + pe_output_psum[i][j];
                end
            end
        end
    end

    // Check if all PEs are done
    wire all_pe_done = &pe_done;

    // Control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            gb_write_enable <= 1'b0;
            pe_start <= 1'b0;
            relu_start <= 1'b0;
            computation_done <= 1'b0;
            result <= 64'b0;
            result_bit_counter <= 6'b0;
            result_serial_shift_enable <= 1'b0;
        end else if (start_computation) begin
            gb_write_enable <= 1'b1;
            pe_start <= 1'b1;
        end else if (all_pe_done) begin
            gb_write_enable <= 1'b0;
            pe_start <= 1'b0;
            relu_start <= 1'b1;
        end else if (relu_done) begin
            relu_start <= 1'b0;
            result <= aggregated_psum;
            computation_done <= 1'b1;
            result_serial_shift_enable <= 1'b1;
        end else if (result_serial_shift_enable) begin
            if (result_bit_counter < 6'd64) begin
                result <= {result[62:0], 1'b0};
                result_bit_counter <= result_bit_counter + 1;
            end else begin
                result_serial_shift_enable <= 1'b0;
            end
        end
    end

    assign serial_data_out = result[63];
endmodule