// Minimal Verilator simulation harness for core_v_mcu
// Drives clock/reset, runs for N cycles, optionally writes VCD trace.
// Usage: ./sim_core_v_mcu [cycles] [trace.vcd]

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcore_v_mcu.h"

static vluint64_t main_time = 0;

double sc_time_stamp() { return (double)main_time; }

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);

    // Parse optional arguments
    uint64_t max_cycles = 2000;
    const char *vcd_file = nullptr;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] != '+' && argv[i][0] != '-') {
            // bare number → cycle count
            char *end;
            uint64_t v = strtoull(argv[i], &end, 10);
            if (*end == '\0') { max_cycles = v; continue; }
            // bare string ending in .vcd → trace file
            if (strstr(argv[i], ".vcd")) { vcd_file = argv[i]; continue; }
        }
    }

    VerilatedContext *ctx = new VerilatedContext;
    ctx->debug(0);
    ctx->traceEverOn(vcd_file != nullptr);

    Vcore_v_mcu *top = new Vcore_v_mcu{ctx};

    VerilatedVcdC *tfp = nullptr;
    if (vcd_file) {
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open(vcd_file);
        printf("Writing VCD trace to: %s\n", vcd_file);
    }

    // Hold reset asserted for 40 half-cycles (20 full clock cycles)
    const uint64_t RESET_CYCLES = 20;

    // Initialise inputs
    top->jtag_tck_i  = 0;
    top->jtag_trst_i = 0;   // JTAG reset asserted (active-low not used here)
    top->jtag_tdi_i  = 0;
    top->jtag_tms_i  = 1;
    top->ref_clk_i   = 0;
    top->rstn_i      = 0;   // chip reset asserted (active-low)
    top->stm_i       = 0;
    top->bootsel_i   = 0;
    top->io_in_i     = 0;

    uint64_t cycle = 0;
    while (!ctx->gotFinish() && cycle < max_cycles) {
        // Deassert reset after RESET_CYCLES
        if (cycle == RESET_CYCLES) {
            top->rstn_i = 1;
            printf("[%lu] Reset deasserted\n", cycle);
        }

        // Rising edge
        top->ref_clk_i = 1;
        top->eval();
        if (tfp) tfp->dump((vluint64_t)(main_time));
        main_time += 5;   // 5 ns half-period → 100 MHz

        // Falling edge
        top->ref_clk_i = 0;
        top->eval();
        if (tfp) tfp->dump((vluint64_t)(main_time));
        main_time += 5;

        cycle++;
    }

    printf("Simulation finished after %lu cycles (time=%lu ns)\n", cycle, main_time);

    if (tfp) { tfp->close(); delete tfp; }
    top->final();
    delete top;
    delete ctx;
    return 0;
}
