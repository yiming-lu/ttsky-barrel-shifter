// Level 1: N-bit rotate-right barrel shifter (N is a power of two).
module n_ror_barrel #(parameter N = 4) (
    input  wire [N-1:0] data_in,
    input  wire [$clog2(N)-1:0] k,
    output wire [N-1:0] data_out
);
    localparam STAGES = $clog2(N);
    wire [(STAGES+1)*N-1:0] stage;
    assign stage[N-1:0] = data_in;
    assign data_out = stage[STAGES*N +: N];

    genvar j, b;
    generate
        for (j = 0; j < STAGES; j = j + 1) begin : row
            for (b = 0; b < N; b = b + 1) begin : mux
                assign stage[(j+1)*N + b] = k[j]
                    ? stage[j*N + ((b + (1 << j)) % N)]
                    : stage[j*N + b];
            end
        end
    endgenerate
endmodule
