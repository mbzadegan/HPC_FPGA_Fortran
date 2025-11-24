// ==========================================================
//  Random Packet Generator using LFSR
//  Works on Xilinx Kintex-7 FPGA
// ==========================================================
module packet_generator (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,        // Start packet generation
    output reg  [31:0] data_out,     // Packet data output
    output reg         data_valid,   // Indicates valid output
    output reg         packet_done   // Pulses high when packet is done
);

    parameter PACKET_WORDS = 32;     // Size of packet in 32-bit words
    reg [7:0]  counter = 0;

    // ------------------------
    // 32-bit LFSR RNG
    // Polynomial: x^32 + x^22 + x^2 + x^1 + 1
    // ------------------------
    reg [31:0] lfsr_reg = 32'hACE1_1234;
    wire lfsr_feedback = lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0];

    always @(posedge clk) begin
        if(rst) begin
            lfsr_reg   <= 32'hACE1_1234;
            counter    <= 0;
            data_out   <= 0;
            data_valid <= 0;
            packet_done <= 0;
        end
        else begin
            packet_done <= 0;

            if(start) begin
                // update the LFSR state
                lfsr_reg <= {lfsr_reg[30:0], lfsr_feedback};

                // output random data
                data_out   <= lfsr_reg;
                data_valid <= 1;

                // packet counter
                counter <= counter + 1;

                // when packet finished
                if(counter == PACKET_WORDS-1) begin
                    data_valid <= 0;
                    packet_done <= 1;
                    counter <= 0;
                end
            end
        end
    end

endmodule
