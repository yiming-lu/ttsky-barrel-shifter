// Level 2: N-bit bidirectional rotate barrel shifter (N is a power of two).
module n_ror_l #(parameter N = 4) (
    input  wire [N-1:0] data_in,
    input  wire [$clog2(N)-1:0] k,
    input  wire left,
    output wire [N-1:0] data_out
);
    localparam STAGES = $clog2(N);
    wire [(STAGES+1)*N-1:0] stage;
    wire [STAGES-1:0] k_eff;
    wire [N-1:0] pre;

    // Left by k == right by (~k + 1) modulo N.
    assign k_eff = k ^ {STAGES{left}};
    assign pre = left ? {data_in[0], data_in[N-1:1]} : data_in;
    assign stage[N-1:0] = pre;
    assign data_out = stage[STAGES*N +: N];

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
endmodule
