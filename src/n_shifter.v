// Level 3: N-bit rotate, logical shift, arithmetic-right shift.
module n_shifter #(parameter N = 4) (
    input  wire [N-1:0] data_in,
    input  wire [$clog2(N)-1:0] k,
    input  wire left,
    input  wire shift,
    input  wire arithmetic,
    output wire [N-1:0] data_out
);
    localparam STAGES = $clog2(N);
    wire [(STAGES+1)*N-1:0] stage;
    wire [STAGES-1:0] k_eff;
    wire [N-1:0] pre;

    assign k_eff = k ^ {STAGES{left}};
    assign pre = left ? {data_in[0], data_in[N-1:1]} : data_in;
    assign stage[N-1:0] = pre;

    genvar j, b;
    generate
        for (j = 0; j < STAGES; j = j + 1) begin : row
            for (b = 0; b < N; b = b + 1) begin : mux
                assign stage[(j+1)*N + b] = k_eff[j]
                    ? stage[j*N + ((b + (1 << j)) % N)]
                    : stage[j*N + b];
            end
        end
    endgenerate

    wire [N-1:0] x;
    assign x = stage[STAGES*N +: N];

    wire [N-1:0] therm;
    wire [N-1:0] mask;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : mask_bits
            assign therm[i] = (i < k);
            assign mask[i] = shift & (left ? therm[i] : therm[N-1-i]);
        end
    endgenerate

    wire kill;
    assign kill = shift & ~left & arithmetic & data_in[N-1];
    assign data_out = (x & ~mask) | ({N{kill}} & mask);
endmodule
