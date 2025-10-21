module main

import capture
import logger
import render
import cursor

// init_x11 serves as a "main" function for x11 based systems
// it initialized the x11 backend and starts the application
pub fn init_x11() {
	logger.debug('initializing x11 backend')

	// start screen capture, is mutable since it changes...
	mut cap := capture.new_x11_capturer() or {
		logger.err('failed to initialize capture: ${err}')
		exit(1)
	}
	logger.info('cap struct created succesfully: ' + cap.str())
	logger.debug('display pointer: ' + cap.get_display_ptr_str())

	// start renderer, it is a window over all the others
	render.init_gl_window()

	// capture + display loop (simplified)
	for {
		// we should only capture the region in a specific zone around the cursor
		x, y, w, h := cursor.get_cursor_with_pad() or {
			logger.err('get cursor failed: ${err}')
			break
		}
		img := cap.capture_region(x, y, w, h) or {
			logger.err('capture failed: ${err}')
			break
		}

		// render the single frames
		render.draw_zoom(img)
	}
}

//  TODO: document init_wayland
pub fn init_wayland() {
	logger.err('wayland not supported yet')
	exit(1)
}
