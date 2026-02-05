# CORDIC Algorithm Implementation with UVM Verification

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A hardware implementation of the CORDIC (COordinate Rotation DIgital Computer) algorithm for computing sine and cosine functions, with a complete UVM-based verification environment.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Verification Environment](#verification-environment)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Test Scenarios](#test-scenarios)
- [Results](#results)
- [Author](#author)

## 🎯 Overview

CORDIC is an efficient iterative algorithm for computing trigonometric functions using only shift and add operations, making it ideal for hardware implementation. This project implements a pipelined CORDIC processor optimized for sine and cosine calculation across the full 0-360° range.

**Key Specifications:**
- **Input:** 17-bit angle representation (0-102944 maps to 0-360°)
- **Output:** 16-bit signed sine and cosine values
- **Tolerance:** ±15 LSB for verification
- **Algorithm:** Rotation mode CORDIC with quadrant handling

## ✨ Features

### Hardware Features
- **Pipelined Architecture** - Multi-stage pipeline for high throughput
- **Pre-Processing Unit** - Quadrant detection and angle normalization
- **Post-Processing Unit** - Sign correction based on input quadrant
- **ROM-based Lookup** - Precomputed arctangent values for iteration stages
- **Fixed-Point Arithmetic** - Optimized for FPGA/ASIC implementation

### Verification Features
- **UVM Testbench** - Industry-standard verification methodology
- **Golden Reference Model** - CSV-based expected value comparison
- **Comprehensive Coverage** - Tests across all four quadrants
- **Scoreboard** - Automatic result checking with tolerance
- **Configurable Tests** - Multiple test scenarios for targeted verification

## 🏗️ Architecture

### RTL Design Hierarchy

```
CORDIC_TOP
├── PRE_PROCESSING_UNIT    # Angle normalization & quadrant detection
├── CORDIC_PIPELINE        # Iterative CORDIC stages
│   ├── CORDIC_X          # X coordinate computation
│   ├── CORDIC_Y          # Y coordinate computation  
│   ├── CORDIC_Z          # Angle accumulation
│   └── ADD_SUB           # Controlled adder/subtractor
├── ROM                    # Arctangent lookup table
└── POST_PROCESSING_UNIT   # Output sign correction
```

### CORDIC Algorithm Flow

1. **Pre-Processing:**
   - Detect input quadrant
   - Normalize angle to first quadrant (0-90°)
   - Store quadrant information for post-processing

2. **Iteration:**
   - For each stage i:
     - X[i+1] = X[i] - d[i] × Y[i] × 2^(-i)
     - Y[i+1] = Y[i] + d[i] × X[i] × 2^(-i)
     - Z[i+1] = Z[i] - d[i] × arctan(2^(-i))
   - Direction d[i] determined by sign of remaining angle

3. **Post-Processing:**
   - Apply sign corrections based on original quadrant
   - Output final sine and cosine values

## 🧪 Verification Environment

### UVM Architecture

```
CORDIC_ENV
├── IP_AGENT (Active)
│   ├── Sequencer       # Test sequence generation
│   ├── Driver          # Drives input angles to DUT
│   └── Monitor         # Captures input transactions
├── OP_AGENT (Passive)
│   └── Monitor         # Captures output transactions
├── Scoreboard          # Compares DUT output vs golden model
└── Virtual Sequencer   # Coordinates test sequences
```

### Key Verification Components

**Transaction Item:**
```systemverilog
class cordic_sequence_item extends uvm_sequence_item;
    rand logic [16:0] Input_angle;  // 0 to 102944 (0-360°)
    logic signed [15:0] Cos_out;    // Cosine output
    logic signed [15:0] Sin_out;    // Sine output
endclass
```

**Scoreboard Features:**
- Loads golden reference from `cordic.csv`
- Compares outputs with ±15 LSB tolerance
- Tracks pass/fail statistics
- Generates comprehensive test report

## 📁 Directory Structure

```
cordic_project/
├── rtl/
│   ├── CORDIC_TOP.v              # Top-level module
│   ├── CORDIC_PIPELINE.v         # Iterative CORDIC stages
│   ├── PRE_PROCESSING_UNIT.v     # Input preprocessing
│   ├── POST_PROCESSING_UNIT.v    # Output postprocessing
│   ├── CORDIC_X.v                # X coordinate update
│   ├── CORDIC_Y.v                # Y coordinate update
│   ├── CORDIC_Z.v                # Angle update
│   ├── ADD_SUB.v                 # Arithmetic unit
│   └── ROM.v                     # Arctangent LUT
├── uvm/
│   ├── cordic_top.sv             # UVM testbench top
│   ├── cordic_test.sv            # Test classes
│   ├── cordic_env.sv             # Environment
│   ├── cordic_sequence_item.sv   # Transaction class
│   ├── cordic_base_sequence.sv   # Base sequences
│   ├── cordic_scoreboard.sv      # Checker
│   ├── cordic_ip_agent.sv        # Input agent
│   ├── cordic_ip_driver.sv       # Input driver
│   ├── cordic_ip_monitor.sv      # Input monitor
│   ├── cordic_op_agent.sv        # Output agent
│   ├── cordic_op_monitor.sv      # Output monitor
│   ├── cordic_if.sv              # Interface
│   ├── pkg.sv                    # UVM package
│   └── cordic.csv                # Golden reference
└── transcript_uvm/
    ├── uvm_transcript            # Simulation log
    └── testbench_output.png      # Waveform capture
```

## 🚀 Getting Started

### Prerequisites

- **Simulator:** QuestaSim/ModelSim, VCS, or compatible UVM-enabled simulator
- **SystemVerilog/UVM Support:** UVM 1.2 or later
- **Files Required:** RTL files, UVM testbench, and `cordic.csv` golden reference

### Running Simulation

1. **Compile RTL and UVM files:**
   ```bash
   # For QuestaSim/ModelSim
   vlog -sv rtl/*.v
   vlog -sv +incdir+uvm uvm/*.sv
   ```

2. **Run specific test:**
   ```bash
   vsim -c cordic_top +UVM_TESTNAME=std_ip_test -do "run -all"
   ```

3. **Available tests:**
   - `zero_ip_test` - Tests angle = 0°
   - `small_ip_test` - Tests small angles
   - `first_quad_ip_test` - Tests 0-90° range
   - `second_quad_ip_test` - Tests 90-180° range
   - `third_quad_ip_test` - Tests 180-270° range
   - `fourth_quad_ip_test` - Tests 270-360° range
   - `std_ip_test` - Standard random test (default)

### Viewing Results

```bash
# Check simulation transcript
cat transcript_uvm/uvm_transcript

# View waveforms
vsim -view transcript_uvm/testbench_output.wlf
```

## 📊 Test Scenarios

### Coverage Plan

| Test Class | Description | Angle Range | Purpose |
|------------|-------------|-------------|---------|
| `zero_ip_test` | Zero angle test | 0° | Verify boundary condition |
| `small_ip_test` | Small angle tests | 0-10° | Verify precision at small angles |
| `first_quad_ip_test` | First quadrant | 0-90° | Verify Q1 operation |
| `second_quad_ip_test` | Second quadrant | 90-180° | Verify Q2 sign handling |
| `third_quad_ip_test` | Third quadrant | 180-270° | Verify Q3 sign handling |
| `fourth_quad_ip_test` | Fourth quadrant | 270-360° | Verify Q4 sign handling |
| `std_ip_test` | Standard random | 0-360° | Full range verification |

### Verification Methodology

1. **Self-Checking:** Scoreboard automatically compares RTL output against golden CSV values
2. **Tolerance-Based:** Accepts results within ±15 LSB to account for fixed-point quantization
3. **Comprehensive Reporting:** Displays pass/fail counts, pass rate, and detailed mismatch information

## 📈 Results

The verification environment generates a detailed report including:

```
========================================
      CORDIC SCOREBOARD REPORT
========================================
Total Tests:  XXX
Passed:       XXX
Failed:       X
Tolerance:    ±15 LSB
Pass Rate:    XX.XX%
========================================
*** ALL TESTS PASSED ***
```

### Performance Metrics
- **Accuracy:** Better than ±15 LSB across full angle range
- **Throughput:** One result per clock cycle (pipelined operation)
- **Latency:** Pipeline depth cycles

## 👨‍💻 Author

**Madhav Kaushik**
- Hardware Design & Verification Engineer
- Specialized in Digital Design and UVM-based Verification

## 📄 License

This project is available under the MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- CORDIC algorithm based on Jack Volder's original 1959 paper
- UVM methodology from Accellera Standards
- Fixed-point optimization techniques from modern FPGA design practices

---

**Note:** For detailed information about CORDIC algorithm theory, refer to:
- Volder, J. E. (1959). "The CORDIC Trigonometric Computing Technique"
- Andraka, R. (1998). "A survey of CORDIC algorithms for FPGA based computers"
