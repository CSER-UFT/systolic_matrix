# Pin-constraint plan for `systolic_array`

The systolic-array top-level interface has 27 FPGA I/O pins:

- 24 data inputs: `inp_west0`, `inp_west3`, `inp_west6`, `inp_north0`,
  `inp_north1`, and `inp_north2` (4 bits each);
- `clk` and `rst`;
- the `done` output.

Create `systolic_array.xdc` in this directory after confirming the exact board
and its master constraints/schematic. The existing `constraints/boolean_board.xdc`
at the project root belongs to the seven-segment design and does not map this
interface.

The XDC needs to:

1. Assign each of the 27 top-level I/O bits to a distinct package pin available
   on the selected board. Use the board's master XDC or schematic; do not infer
   pin numbers from the FPGA part alone.
2. Set the correct `IOSTANDARD` for each assigned pin according to its FPGA
   bank voltage and board wiring.
3. Assign `clk` to the board's clock source and define its actual frequency
   with `create_clock`. The existing seven-segment constraint uses pin `F14`
   at 100 MHz, but reuse that assignment only if the selected board is the same.
4. Decide how the 24 data bits and `rst` will be driven. If external synchronous
   hardware drives them, add input delay constraints based on that interface's
   timing. If they are switches or buttons, confirm the intended electrical
   mapping and whether the RTL needs input synchronization/debouncing.
5. Add output delay constraints for `done` when it drives a timed external
   interface. Do not add guessed delays or blanket false paths.

The hardware Tcl build and power scripts expect the completed XDC at
`src/hardware/constraints/systolic_array.xdc`. The part configured in those
scripts (`xc7s50csga324-1`) is inherited from the existing project and must also
be checked against the actual board.
