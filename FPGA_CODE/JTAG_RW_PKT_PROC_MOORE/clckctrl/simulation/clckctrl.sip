set_global_assignment -entity "clckctrl" -library "lib_clckctrl" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "clckctrl" -library "lib_clckctrl" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "clckctrl" -library "lib_clckctrl" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_clckctrl" -name SPD_FILE [file join $::quartus(sip_path) "../clckctrl.spd"]
set_global_assignment -library "lib_clckctrl" -name MISC_FILE [file join $::quartus(sip_path) "../../clckctrl.qsys"]

set_global_assignment -library "lib_clckctrl" -name MISC_FILE [file join $::quartus(sip_path) "clckctrl.vhd"]
set_global_assignment -library "lib_clckctrl" -name MISC_FILE [file join $::quartus(sip_path) "submodules/clckctrl_altclkctrl_0.v"]
