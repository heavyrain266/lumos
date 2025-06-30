package lumos

import "core:log"
import "core:time"
import "base:runtime"

import sdl "vendor:sdl3"

shared_context : runtime.Context

sdl_log :: proc "c" (userdata: rawptr, category: sdl.LogCategory, priority: sdl.LogPriority, message: cstring) {
	context = (cast(^runtime.Context)userdata)^

	level: log.Level

	switch priority {
	case .INFO: level = .Info
	case .WARN: level = .Warning
	case .ERROR: level = .Error
	case .CRITICAL: level = .Fatal
	case .INVALID, .TRACE, .VERBOSE, .DEBUG: level = .Debug
	}

	log.log(level, message)
}

main :: proc() {
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	context.logger.options = log.Options {
		.Terminal_Color, .Level, .Short_File_Path, .Line, .Procedure,
	}

	shared_context = context

	sdl.SetLogPriorities(.VERBOSE)
	sdl.SetLogOutputFunction(sdl_log, &shared_context)

	ensure(sdl.SetAppMetadata("lumos", "dev-2025-06", "com.example.lumos"))
	ensure(sdl.Init({.VIDEO, .EVENTS})); defer sdl.Quit()

	window: ^sdl.Window = sdl.CreateWindow("Lumos", 1100.0, 685.0, sdl.WindowFlags{
		.VULKAN, .HIDDEN, .RESIZABLE, .HIGH_PIXEL_DENSITY,
	})
	defer sdl.DestroyWindow(window)

	sdl.ShowWindow(window)

	event_loop: for {
		defer free_all(context.temp_allocator)

		event: sdl.Event; for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				break event_loop
			}
		}

		time.sleep(16 * time.Millisecond)
	}
}
