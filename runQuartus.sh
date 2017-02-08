#!/bin/sh
export LD_LIBRARY_PATH=/opt/intelFPGA_lite/16.1/quartus/linux64/
export PATH=/opt/intelFPGA_lite/16.1/quartus/bin:$PATH
quartus FPGA_CODE/JTAG_RW_PKT_PROC/DE0_Nano_project_Base.qpf
