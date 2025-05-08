filename = convert
pcf_file = ../common/iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).v
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc --freq 6
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
#rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin // Uncomment if using Linux
	del /s /q $(filename).blif $(filename).asc $(filename).json $(filename).bin