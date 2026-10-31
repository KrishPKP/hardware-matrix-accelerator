# FPGA Matrix Multiplication Accelerator

A parameterized matrix-multiplication accelerator implemented in SystemVerilog and targeted to an Altera Cyclone V GX FPGA.

The project explores hardware architectures for matrix multiplication, starting with a resource-efficient sequential design and progressing toward more parallel implementations. The current version uses a single multiply-accumulate (MAC) datapath controlled by a finite-state machine and has been verified against a Python reference model using randomized test vectors.

## Current Status

- Parameterized SystemVerilog matrix multiplier
- Configurable matrix dimension and data width
- Reusable multiply-accumulate unit
- FSM-based controller
- Supports multiple matrix sizes, including 2×2 and 4×4
- Python golden/reference model
- Automated file-based SystemVerilog verification
- 100 randomized test cases passed
- Successfully synthesized in Quartus Prime for an Altera Cyclone V GX FPGA
- Current sequential implementation uses:
  - 1 DSP element
  - 423 logic cells

Target FPGA:

```text
Altera Cyclone V GX
5CGXFC5C6F27C7
```

## Architecture

The current design uses a single MAC unit that is reused across all matrix elements.

For matrix multiplication:

```text
C[i][j] = Σ A[i][k] × B[k][j]
```

The controller tracks three indices:

```text
i = output row
j = output column
k = position within the dot product
```

For each output element, the accelerator:

```text
CLEAR accumulator
        ↓
MAC A[i][0] × B[0][j]
        ↓
MAC A[i][1] × B[1][j]
        ↓
...
        ↓
MAC A[i][N-1] × B[N-1][j]
        ↓
STORE result in C[i][j]
```

The design then advances to the next output element until the complete matrix has been calculated.

### FSM

The controller uses five states:

```text
IDLE
  ↓
CLEAR
  ↓
MAC
  ↓
STORE
  ↓
DONE
```

`MAC` repeats until all terms for the current dot product have been accumulated.

## Parameterization

The design is parameterized using:

```systemverilog
parameter int N = 4;
parameter int DATA_WIDTH = 8;
```

Derived widths are calculated automatically.

For unsigned inputs:

```text
ACC_WIDTH = 2 × DATA_WIDTH + ceil(log2(N))
```

For the default configuration:

```text
N = 4
DATA_WIDTH = 8
ACC_WIDTH = 18
```

The same RTL has been tested with both 2×2 and 4×4 matrices.

## Sequential Architecture

The current architecture deliberately prioritizes low hardware usage over throughput.

A 4×4 matrix multiplication contains:

```text
16 output elements
×
4 multiply-accumulate operations per output
=
64 MAC operations
```

Because the architecture contains only one MAC datapath, these operations are performed sequentially.

For each output element, the controller currently requires:

```text
1 CLEAR cycle
4 MAC cycles
1 STORE cycle
```

giving approximately:

```text
16 × 6 = 96 core computation/control cycles
```

for a 4×4 multiplication, excluding small start/completion overhead depending on the measurement convention.

This architecture provides the baseline for future parallel implementations.

## Verification

The RTL is verified against an independent Python implementation of matrix multiplication.

The Python golden model performs conventional matrix multiplication:

```python
def matmul(A, B):
    n = len(A)
    C = [[0 for _ in range(n)] for _ in range(n)]

    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]

    return C
```

A Python test-vector generator:

1. Generates random matrices
2. Calculates the expected output using the golden model
3. Writes A, B, and expected C values to text files

The SystemVerilog testbench then:

1. Reads the generated matrices
2. Loads A and B into the DUT
3. Starts the accelerator
4. Waits for `done`
5. Compares every hardware output against the Python result
6. Reports a failure immediately if any value differs

The current design has passed:

```text
100 / 100 randomized matrix multiplication tests
```

as well as directed tests including known 2×2 and 4×4 matrix products.

## FPGA Synthesis

The sequential architecture was synthesized using Quartus Prime Lite for:

```text
Family: Cyclone V
Device: 5CGXFC5C6F27C7
```

Initial Analysis & Synthesis results:

| Resource | Usage |
|---|---:|
| DSP elements | 1 |
| Logic cells | 423 |
| Matrix size | 4×4 |
| Input width | 8 bits |
| Accumulator width | 18 bits |

The single inferred DSP reflects the intentionally sequential architecture, which reuses one MAC datapath across the complete matrix multiplication.

The original accelerator module exposes the matrices directly as ports, resulting in a large number of top-level I/O signals. A board-level wrapper will be added before physical FPGA deployment.

## Repository Structure

```text
hardware-matrix-accelerator/
│
├── rtl/
│   ├── mac_unit.sv
│   └── MatrixMultSeq.sv
│
├── tb/
│   └── tb_MatrixMultSeq_random.sv
│
├── software/
│   ├── reference_model.py
│   └── generate_vectors.py
│
├── test_vectors/
│   ├── A.txt
│   ├── B.txt
│   └── expected.txt
│
├── results/
│   └── sequential_baseline.txt
│
└── README.md
```

## Running Verification

Generate randomized test vectors:

```powershell
python software\generate_vectors.py
```

Compile the SystemVerilog design and testbench with Icarus Verilog:

```powershell
iverilog -g2012 -o simv rtl\mac_unit.sv rtl\MatrixMultSeq.sv tb\tb_MatrixMultSeq_random.sv
```

Run the simulation:

```powershell
vvp simv
```

A successful randomized regression reports:

```text
ALL 100 RANDOM TESTS PASSED
```

## Design Tradeoff

The sequential implementation intentionally trades performance for hardware efficiency.

```text
Sequential architecture

1 MAC / DSP
↓
low hardware usage
↓
more clock cycles
↓
lower throughput
```

A future parallel architecture will perform multiple products simultaneously:

```text
Parallel architecture

multiple MAC / DSP units
↓
higher hardware usage
↓
fewer clock cycles
↓
higher throughput
```

Both implementations will be synthesized on the same Cyclone V device to quantify the tradeoff between resource usage and performance.

## Next Steps

- Create a board-level FPGA wrapper
- Deploy and validate the accelerator on the physical Cyclone V GX
- Add timing constraints and measure Fmax
- Record fitted ALM, register, DSP, and timing results
- Implement a multi-MAC parallel architecture
- Compare sequential and parallel latency/resource usage
- Implement a systolic processing element
- Scale to a 2×2 and 4×4 systolic array
- Add a host interface for loading matrices and retrieving results

## Project Goal

The goal of this project is not only to implement matrix multiplication in RTL, but to study how different digital architectures affect:

```text
latency
throughput
DSP usage
logic utilization
clock frequency
hardware parallelism
```

The sequential implementation serves as the resource-efficient baseline for these architectural comparisons.