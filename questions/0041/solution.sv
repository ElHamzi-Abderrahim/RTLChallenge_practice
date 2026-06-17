module hamming_encoder (
    input  wire [7:0]      data_in,
    output wire [12:0]     encoded_out,
    output wire [4:0]      parity_bits
);

    // SECDED Hamming(13,8) Code
    // Position: 12 11 10  9  8  7  6  5  4  3  2  1  0
    // Bit Type: P4 D7 D6 D5 D4 P3 D3 D2 D1 P2 D0 P1 P0
    // P0 at position 0, P1 at position 1, P2 at position 3, P3 at position 7
    // P4 is the overall parity bit for SECDED

    wire p0, p1, p2, p3, p4;
    wire d0, d1, d2, d3, d4, d5, d6, d7;

    assign d0 = data_in[0];
    assign d1 = data_in[1];
    assign d2 = data_in[2];
    assign d3 = data_in[3];
    assign d4 = data_in[4];
    assign d5 = data_in[5];
    assign d6 = data_in[6];
    assign d7 = data_in[7];

    // Hamming parity bit calculations (even parity)
    // P0 (position 1 in 1-based): covers positions with bit 0 set: 1,3,5,7,9,11
    // In our encoding: positions 0,2,4,6,8,10
    assign p0 = d0 ^ d1 ^ d3 ^ d4 ^ d6;

    // P1 (position 2 in 1-based): covers positions with bit 1 set: 2,3,6,7,10,11
    // In our encoding: positions 1,2,5,6,9,10
    assign p1 = d0 ^ d2 ^ d3 ^ d5 ^ d6;

    // P2 (position 4 in 1-based): covers positions with bit 2 set: 4,5,6,7,12
    // In our encoding: positions 3,4,5,6,11
    assign p2 = d1 ^ d2 ^ d3 ^ d7;

    // P3 (position 8 in 1-based): covers positions with bit 3 set: 8,9,10,11,12
    // In our encoding: positions 7,8,9,10,11
    assign p3 = d4 ^ d5 ^ d6 ^ d7;

    // P4: Overall parity bit for entire codeword (SECDED)
    assign p4 = p0 ^ p1 ^ d0 ^ p2 ^ d1 ^ d2 ^ d3 ^ p3 ^ d4 ^ d5 ^ d6 ^ d7;

    // Assemble encoded output
    // Position: 12 11 10  9  8  7  6  5  4  3  2  1  0
    // Bit:      P4 D7 D6 D5 D4 P3 D3 D2 D1 P2 D0 P1 P0
    assign encoded_out = {p4, d7, d6, d5, d4, p3, d3, d2, d1, p2, d0, p1, p0};
    assign parity_bits = {p4, p3, p2, p1, p0};


endmodule
