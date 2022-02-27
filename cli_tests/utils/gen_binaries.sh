#!/bin/bash

echo "Generating cli_test.bin for QSPI Flashing and cli_sim.bin for simulation testing"
cat  "../header.bin" "cli_test.bin"  >  "cli.bin"
cat  "../header_sim.bin" "cli_test.bin"  >  "cli_sim.bin"
echo "Done."

echo "Generating c array file for loading the app by an external host over I2C"
cd ../utils/bin2carray/bin/Debug
./bin2carray ../../../../Default/cli.bin
echo "Done. Generated c array file is in cli_test/utils/generated_c_array_file"

echo "Generating interleaved RAM initalization files for simulation testing"
cd ../../../InterleavedRAMFileGen/bin/Debug
./InterleavedRAMFileGen ../../../../Default/cli_test.bin
echo "Done. Generated files are in cli_test/utils/memoryInitFiles"

echo "Generating memory initialization file for simulated flash model"
cd ../../../bin2txt/bin/Debug
./bin2txt ../../../../Default/cli_sim.bin
./bin2txt ../../../../Default/cli.bin
echo "Done. Generated file is in cli_test/utils/memoryInitFiles"
