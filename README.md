# FPGAIPFilter

Uses: Linux, Quartus, DE0-Nano cyclone board.

Develop simple clash IP packet filter for the DE0-Nano board.

For test data input use USB Blaster.

## Status

- Skeleton and tooling are in place (POC)
- Refactor JTAG interfacing
- Move packet processor to clash dataflow?

## Todo
- See projects / issues

## Maybe
- FTDI haskell lib is old - fix?
- bindings-libftdi, could improve error handling - expose more of libftdi

# Done
- Using https://github.com/victoredwardocallaghan/bindings-libftdi (forked @ https://github.com/tau-tao/bindings-libftdi) - Can drive the "InitialTest.sof" sample from test/FtdiTest1.hs (mods to JtagRW.hs - addressing see Top.vhd)
- Can drive the PacketProcessor derived from clash
- Notes on the addressing changes when adding other JTAG components such as JTAG readable RAM and Sig2 logic analyser
- Scripts for extracting RAM.
- Bidirectional data transfer via USB Blaster JTAG

### Resources:

- Detailed info: https://www.ovro.caltech.edu/~dwh/correlator/pdf/vjtag.pdf
- Altera Ref: https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug_virtualjtag.pdf
- FTDI access: https://github.com/GeezerGeek/open_sld
- A UART impl: http://idlelogiclabs.com/2014/07/12/virtual-com-port-connection-de0-nano-vj-uart/
- DE0-Nano interfacing: http://idlelogiclabs.com/2012/04/15/talking-to-the-de0-nano-using-the-virtual-jtag-interface/
