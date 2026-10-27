# Repository Guidelines

## Project Structure & Module Organization

The active FPGA matrix-multiplier design lives under `src/hardware/`:

- `rtl/` contains synthesizable Verilog (`block.v`, `systolic_array.v`) and the
  self-checking testbench (`sys_array_tb.v`).
- `tcl/` contains Vivado batch scripts for build, simulation/power analysis,
  and programming.
- `constraints/` contains XDC timing and board constraints; read its README
  before changing pin mappings.
- `src/common/` holds the hexadecimal 16×16 input matrices used by the
  testbench. `src/docs/reports/` holds engineering notes and results.

The root-level seven-segment files and `constraints/boolean_board.xdc` are a
separate board example. Do not mix them into the systolic-array flow.

## Build, Test, and Development Commands

Run commands from the repository root with Vivado 2022.2 on `PATH`:

```sh
make build  # synthesize, implement, and generate implementation reports
make sim    # simulate the array, write a VCD, and run power analysis
make program # program the configured FPGA target
make clean  # remove generated build and Vivado artifacts
```

For the array-specific flow, invoke `vivado -mode batch -source
src/hardware/tcl/build.tcl` or `src/hardware/tcl/sim_power.tcl` directly.
Treat `make` (build + sim + program) cautiously: programming requires a
connected, correctly configured board.

## Coding Style & Naming Conventions

Use Verilog-2001 and four-space indentation. Keep module names and filenames
lowercase with underscores (for example, `systolic_array.v`); use descriptive
signal names such as `inp_west` and `RESULT_WIDTH`. Align port connections and
preserve parameterized widths rather than introducing hard-coded bus slices.
Use `localparam` for internal constants and named `generate` blocks for
hierarchical array instances. Keep comments focused on timing, dimensions, and
hardware intent. No formatter or linter is currently configured.

## Testing Guidelines

Update `src/hardware/rtl/sys_array_tb.v` with every RTL behavior change. The
testbench reads `src/common/matrizA.txt` and `matrizB.txt`, computes a software
reference, and must end with `PASS` for all 256 results. Run `make sim` after
changes to RTL, testbench, matrices, or timing. Exercise reset and `done`
timing when changing array dimensions or pipeline latency.

## Commit & Pull Request Guidelines

Recent history uses short imperative subjects, sometimes with a prefix (for
example, `Feat: estrutura inicial` and `enforce 16 bits evaluation`). Keep
commits small and focused; state the affected RTL or flow. PRs should describe
the hardware or timing change, list simulation/build commands and results, and
include relevant report or waveform evidence. Call out constraint or board
assumptions explicitly.
