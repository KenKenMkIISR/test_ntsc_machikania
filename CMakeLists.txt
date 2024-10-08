cmake_minimum_required(VERSION 3.13)

# Pull in SDK (must be before project)
include(pico_sdk_import.cmake)

project(puerulus C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# include configure file for specifying target
include(config.cmake)

# Initialize the SDK
pico_sdk_init()

if (TARGET tinyusb_device)
	# Create library including shared files
	add_library(shared_files
		main.c
		api.c
		library.c
		compiler.c
		run.c
		statements.c
		functions.c
		integer.c
		float.c
		string.c
		globalvars.c
		variable.c
		operators.c
		value.c
		cmpdata.c
		error.c
		memory.c
		class.c
		file.c
		display.c
		timer.c
		io.c
		music.c
		core1.c
		hexfile.c
		debug.c	
		exception.c
		rtc.c
		interface/rp2040_pwm_ntsc_textgraph.c
		interface/text_graph_library.c
		interface/fontdata.c
		interface/ff.c
		interface/pico-sdmm.c
		interface/fileselect.c
	)
	target_link_libraries(shared_files 
		pico_stdlib
		pico_multicore
		hardware_spi
		hardware_pwm
		hardware_adc
		hardware_i2c
		hardware_exception
		hardware_rtc
		hardware_dma
	)
	
	# Create wifi library
	if (MACHIKANIA_WIFI STREQUAL "withwifi")
		add_library(wifi_files
			wifi/withwifi.c
			wifi/wifierror.c
			wifi/socket.c
			wifi/picow_ntp_client.c
			wifi/picow_tcp_client.c
			wifi/picow_tcp_server.c
			wifi/picow_tls_client.c
		)
		target_link_libraries(wifi_files
			pico_cyw43_arch_lwip_threadsafe_background
			pico_lwip_mbedtls
			pico_mbedtls
		)
		target_include_directories(wifi_files PUBLIC
			${CMAKE_CURRENT_LIST_DIR}
			${CMAKE_CURRENT_LIST_DIR}/wifi
		)
		target_link_libraries(wifi_files 
			pico_stdlib
		)
	else()
		add_library(wifi_files
			wifi/withoutwifi.c
		)
		target_link_libraries(wifi_files 
			pico_stdlib
		)
	endif()
	
	# Create Auxiliary code library (include file in subdirectory)
	include(auxcode/auxcode.cmake)
	# The default definition is as follows
		# add_library(aux_files
		#	auxcode/auxcode.c
		# )
		# target_link_libraries(aux_files 
		#	pico_stdlib
		# )
		
	# puerulus_kb.uf2
	add_executable(puerulus_kb
		editor.c
		interface/usbkeyboard.c
		interface/hid_virtual_keytable.c
		interface/keyinput.c
		withkeyboard.c
	)
	target_link_libraries(puerulus_kb shared_files)
	target_link_libraries(puerulus_kb wifi_files)
	target_link_libraries(puerulus_kb aux_files)
	target_link_libraries(puerulus_kb tinyusb_board)
	target_link_libraries(puerulus_kb tinyusb_host)
	target_include_directories(puerulus_kb PRIVATE ${CMAKE_CURRENT_LIST_DIR}/interface)

	# puerulus.uf2
	add_executable(puerulus
		withoutkeyboard.c
		pcconnect.c
	)
	target_link_libraries(puerulus shared_files)
	target_link_libraries(puerulus wifi_files)
	target_link_libraries(puerulus aux_files)

	# enable usb output, disable uart output
	pico_enable_stdio_usb(puerulus_kb 0)
	pico_enable_stdio_usb(puerulus 1)
	pico_enable_stdio_uart(puerulus_kb 0)
	pico_enable_stdio_uart(puerulus 0)

	# create map/bin/hex/uf2 file etc.
	pico_add_extra_outputs(puerulus_kb)
	pico_add_extra_outputs(puerulus)

	# use custom linker script
	if (MACHIKANIA_WIFI STREQUAL "withwifi") 
		pico_set_linker_script(puerulus_kb ${CMAKE_CURRENT_SOURCE_DIR}/wifi/memmap_machikania.ld)
		pico_set_linker_script(puerulus ${CMAKE_CURRENT_SOURCE_DIR}/wifi/memmap_machikania.ld)
	else()
		pico_set_linker_script(puerulus_kb ${CMAKE_CURRENT_SOURCE_DIR}/memmap_machikania.ld)
		pico_set_linker_script(puerulus ${CMAKE_CURRENT_SOURCE_DIR}/memmap_machikania.ld)
	endif()
	
	# set compile definitions
	target_compile_definitions(shared_files PUBLIC MACHIKANIA_CONFIG="./config/${MACHIKANIA_BUILD}.h")
	target_compile_definitions(wifi_files PUBLIC MACHIKANIA_CONFIG="./config/${MACHIKANIA_BUILD}.h")
	target_compile_definitions(aux_files PUBLIC MACHIKANIA_CONFIG="./config/${MACHIKANIA_BUILD}.h")
	if (MACHIKANIA_DEBUG_MODE)
		target_compile_definitions(shared_files PUBLIC MACHIKANIA_DEBUG_MODE)
		target_compile_definitions(wifi_files PUBLIC MACHIKANIA_DEBUG_MODE)
		target_compile_definitions(aux_files PUBLIC MACHIKANIA_DEBUG_MODE)
	endif()
	if (MACHIKANIA_WIFI STREQUAL "withwifi")
		target_compile_definitions(wifi_files PUBLIC PICO_STACK_SIZE=4096)
		target_compile_definitions(wifi_files PUBLIC PICO_HEAP_SIZE=4096)
		#target_compile_definitions(wifi_files PRIVATE machikania_dummy=6)
	endif()
	
elseif(PICO_ON_DEVICE)
	message(WARNING "not building kmbasic because TinyUSB submodule is not initialized in the SDK")
endif()
