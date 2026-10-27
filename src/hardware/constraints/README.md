# Pin constraints for `systolic_array`

The supplied `systolic_array.xdc` is for implementation, utilization, power,
and internal timing analysis. It constrains only the 100 MHz board clock. This
lets Vivado time the synchronous paths inside the 16x16 array without inventing
electrical or timing properties for a data interface that does not yet exist.

The current top-level interface has 256 data-input bits (`inp_west` and
`inp_north`, 128 bits each), plus `clk`, `rst`, and `done`. It is not an
appropriate direct board interface for bitstream programming.

The XDC needs to:

1. Assign each top-level I/O bit actually used by the board interface to a
   distinct package pin available
   on the selected board. Use the board's master XDC or schematic; do not infer
   pin numbers from the FPGA part alone.
2. Set the correct `IOSTANDARD` for each assigned pin according to its FPGA
   bank voltage and board wiring.
3. Assign `clk` to the board's clock source and define its actual frequency
   with `create_clock`. The existing seven-segment constraint uses pin `F14`
   at 100 MHz, but reuse that assignment only if the selected board is the same.
4. Decide how the data bits and `rst` will be driven. If external synchronous
   hardware drives them, add input delay constraints based on that interface's
   timing. If they are switches or buttons, confirm the intended electrical
   mapping and whether the RTL needs input synchronization/debouncing.
5. Add output delay constraints for `done` when it drives a timed external
   interface. Do not add guessed delays or blanket false paths.

The hardware Tcl build and power scripts expect the completed XDC at
`src/hardware/constraints/systolic_array.xdc`. The part configured in those
scripts (`xc7s50csga324-1`) is inherited from the existing project and must also
be checked against the actual board.
