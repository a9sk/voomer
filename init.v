module main

import capture
import logger
import render
import cursor

// TODO: migrate to using App struct:
// struct App {
//    capturer capture.X11Capturer
//    renderer render.GLXWindow
// }

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

	// note: i am not using gl at the moment, for more infos check out the render/gl.v file
	// start renderer, it is a window over all the others
	// render.init_gl_window(cap.display) or { logger.err('gl window initialization failed: ${err}') }

	mut renderer := render.new_renderer() or {
		logger.err('failed to create a new renderer: ${err}')
		exit(1)
	}

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
		renderer.draw_zoom(img, w, h)
	}
}

//  TODO: document init_wayland
pub fn init_wayland() {
	logger.err('wayland not supported yet')
	exit(1)
}
