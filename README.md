# silicon-operator

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

Set the design top, RTL file list, and testbench in `project.mk`. Update
`syn/constraints.sdc` for the design's ports and timing.

## What the flow does

It runs the usual digital design path: RTL simulation, standard-cell synthesis,
place and route, then reports and SVG previews. Outputs go under `build/`.
This setup uses the VM's educational GPDK045 collateral. It does not produce
valid GDSII or signoff DRC/LVS results.
