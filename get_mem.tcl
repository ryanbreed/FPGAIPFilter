begin_memory_edit -hardware_name "USB-Blaster \[1-1\]" -device_name "@1: EP3C25/EP4CE22 (0x020F30DD)"
puts [read_content_from_memory -instance_index 0 -start_address 0 -word_count 8192 -content_in_hex]
end_memory_edit