# Remove comment in following line for DEBUG_MODE
# This mode is used also for embedded system
#set(MACHIKANIA_DEBUG_MODE 1)

# Select a configuration from following set statements

# Raspberry Pi Pico + NTSC Video out
# YD-RP2040 + NTSC Video
#set(MACHIKANIA_BUILD pico_ntsc)

# Seeed XIAO RP2040 for embedded development  
# Useful for using UART with XIAO RP2040
#set(MACHIKANIA_BUILD xiao_embed)

# Seeed XIAO RP2040 + NTSC Video out
#set(MACHIKANIA_BUILD xiao_ntsc)

# Raspberry Pi Pico W + NTSC Video out + Wifi
set(MACHIKANIA_BUILD pico_w_ntsc)

# Do not touch the lines below

# Force DEBUG_MODE for XIAO board
if (MACHIKANIA_BUILD STREQUAL "xiao_embed")
	set(MACHIKANIA_DEBUG_MODE 1)
endif()

# Select graphic library
set(MACHIKANIA_GRAPH_LIB ntsc_video)

if (MACHIKANIA_BUILD STREQUAL "pico_w_ntsc")
	set(MACHIKANIA_WIFI withwifi)
	set(PICO_BOARD pico_w)
else()
	set(MACHIKANIA_WIFI withoutwifi)
	set(PICO_BOARD pico)
endif()
