# silicon-operator

A small, non-pipelined 32-bit CPU built as an educational VLSI project.
It has 16 general-purpose registers, a 256-word instruction ROM, a 256-word data RAM,
and 16-bit input and output ports. Instructions are 32 bits wide, with an 8-bit opcode.

## Build results

The checked-in results are from Cadence Encounter using the GPDK045 slow corner at 1.08 V and 125 °C.

### Timing

Post-route setup analysis reports positive slack in every path group:

| Path group           | Worst slack |
| -------------------- | ----------: |
| Register to register |    1.007 ns |
| Input to register    |    7.447 ns |
| Register to output   |    8.519 ns |

Total negative slack is 0 ns, with no violating paths across 26,863 analyzed
setup paths. The synthesis report, before place and route, reports 4.099 ns
of timing slack on its critical path.

### Power

The post-route estimate is 25.55 mW total:

| Component |     Power |
| --------- | --------: |
| Internal  | 18.152 mW |
| Switching |  7.392 mW |
| Leakage   | 0.0052 mW |

Sequential cells account for 13.72 mW and combinational logic for 11.83 mW.
This is an estimate, not a measurement. The report has no user-defined
activity file and uses the tool's default primary-input activity.

### Physical design

| Metric             |        Result |
| ------------------ | ------------: |
| Placed cell area   | 126,874.1 µm² |
| Cell count         |        32,210 |
| Gate count         |       123,658 |
| Routed wire length |    906,067 µm |
| Vias               |       260,486 |
| DRC violations     |             0 |
| Routing failures   |             0 |

## Design diagrams

### CPU architecture

```mermaid
flowchart LR
    subgraph IOSystem[Input and output]
        INPUT[Input devices] --> IN_IF[Input interface]
        OUT_IF[Output interface] --> OUTPUT[Output devices]
    end

    subgraph CPUCore[CPU]
        FETCH[Fetch instruction] --> DECODE[Decode instruction]
        DECODE --> CONTROL[Control unit]
        CONTROL --> EXECUTE[Execute operation]
        EXECUTE --> WRITEBACK[Write result]
        WRITEBACK --> FETCH
        REGISTERS[Registers] <--> EXECUTE
        ALU[ALU] <--> EXECUTE
        PC[Program counter] --> FETCH
        CONTROL --> BRANCH[Branch unit]
        FLAGS[Status flags] --> BRANCH
        BRANCH --> PC
        EXECUTE --> FLAGS
    end

    subgraph Memory[Memory]
        PROGRAM[ROM]
        DATA[RAM]
    end

    subgraph Interconnect[System interconnect]
        BUS[System bus]
    end

    IN_IF --> BUS
    BUS --> OUT_IF
    BUS <--> REGISTERS
    PROGRAM --> FETCH
    BUS <--> DATA
    WRITEBACK --> BUS
```

### RTL architecture

```mermaid
flowchart LR
    CLK[Clock and reset] --> CPU[Microprocessor]
    CPU --> CU[Control unit]
    CPU --> DP[Datapath]
    CPU --> ROM[ROM]
    CPU --> RAM[RAM]

    subgraph Control[Control unit]
        IR[Instruction register] --> DEC[Instruction decoder]
        DEC --> SEQ[Fetch / execute controller]
        SEQ --> CTL[Control signals]
        ALU_EQ[ALU equality] --> FLAGS[Flags]
        FLAGS --> BR[Branch unit]
        BR --> CTL
    end

    subgraph Execute[Datapath]
        PC[Program counter] --> ADDR[Address bus]
        RF[Register file] --> ALU[ALU]
        RF --> DBUS[Data bus]
        ALU --> DBUS
        DBUS --> RF
        INPUT[16-bit input pins] --> DBUS
        DBUS --> OUTREG[Output register]
        OUTREG --> OUTPUT[16-bit output pins]
    end

    CTL --> IR
    CTL --> PC
    CTL --> RF
    CTL --> ALU
    CTL --> DBUS
    CTL --> BR
    CTL --> RAM
    CTL --> ADDR
    ADDR --> CPU
    CPU --> ROM
    ROM --> CPU
    CPU --> RAM
    RAM --> CPU
    CPU --> IR
    CPU --> DBUS
    ALU --> ALU_EQ
    RF --> RAM
    CTL --> OUTREG
    CPU --> HALTED[Halted status]
```

### CPU layout

![Placed chip layout](assets/layout.png)

### CPU Schematics

![CPU](assets/schematics/M.avif)

### Schematics of Some Important Modules

#### ALU

![ALU](assets/schematics/ALU.avif)

#### Datapath

![Datapath](assets/schematics/datapath.avif)

#### Control unit

![Control unit](assets/schematics/CU.avif)

#### Instruction decoder

![Instruction decoder](assets/schematics/decoder.avif)

#### Registers

![Registers](assets/schematics/registers.avif)

#### Bus

![Bus](assets/schematics/bus.avif)

## Supported instructions

| Opcode | Instruction | Operation                           |
| ------ | ----------- | ----------------------------------- |
| `00`   | NOP         | No operation                        |
| `01`   | MOVI        | Sign-extended immediate to register |
| `02`   | MOV         | Copy register                       |
| `03`   | ADD         | Add registers                       |
| `04`   | SUB         | Subtract registers                  |
| `05`   | CMP         | Set zero flag if equal              |
| `06`   | LOAD        | RAM to register                     |
| `07`   | STORE       | Register to RAM                     |
| `08`   | JMP         | Absolute jump                       |
| `09`   | BEQ         | Branch if equal                     |
| `0A`   | BNE         | Branch if not equal                 |
| `0B`   | IN          | Input pins to register              |
| `0C`   | OUT         | Register to output pins             |
| `FF`   | HALT        | Stop execution                      |

## Build and inspect

Run these commands in the Cadence VM:

```sh
make test           # Run the RTL testbench
make build          # Test, synthesize, place and route, and generate reports
make view-sim       # Open the simulation waveform in SimVision
make view-schematic # Open the synthesized schematic in RTL Compiler
make view-layout    # Open the placed design in Encounter
make view-reports   # Read the combined build reports
make clean          # Remove generated files
```
