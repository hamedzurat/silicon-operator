# silicon-operator

Small, non-pipelined 32-bit integer CPU for an educational VLSI project.
The CPU has 16 general-purpose registers, a 256 x 32-bit instruction ROM, a
256 x 32-bit data RAM, fixed 16-bit input/output ports, and fixed 32-bit
instructions with an 8-bit opcode field.

## Commands

Run these in the Cadence VM:

```sh
make test           # Simulate RTL and run the testbench
make build          # Test, synthesize, place and route, then make reports and images
make view-sim       # Open the waveform in SimVision
make view-schematic # Open the RTL in SimVision's schematic tracer
make view-layout    # Open the placed and routed design in Encounter
make view-reports   # Read the combined reports
make clean          # Remove generated files
```

## Supported opcodes

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
