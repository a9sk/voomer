module render

import logger
import gg
import cursor
import capture
import time
import math

pub struct GGRenderer {
	cap &capture.X11Capturer // keep a pointer to the capturer
pub mut:
	gg &gg.Context // context used for rendering
}

// new_renderer uses gg's new_context function and
// returns a renderer (for now it is just a pointer to a gg.Context)
pub fn new_renderer(cap &capture.X11Capturer) !&GGRenderer {
	logger.debug('new_renderer start function')

	mut renderer := &GGRenderer{
		gg:  unsafe { nil }
		cap: cap
	}

	// ref: https://github.com/vlang/v/blob/master/vlib/gg
	// fn new_context(cfg Config) &Context
	// new_context returns an initialized Context allocated on the heap.
	renderer.gg = gg.new_context(
		width:         800
		height:        600
		create_window: true
		window_title:  'voomer'
		frame_fn:      fn [mut renderer] (mut ctx gg.Context) {
			if renderer == unsafe { nil } {
				logger.err('renderer is nil in frame')
				return
			}

			// capture region around cursor
			x, y, w, h := cursor.get_cursor_with_pad(renderer.cap.display, renderer.cap.root) or {
				logger.err('get cursor failed: ${err}')
				return
			}

			// capture_region may return an XImage pointer; we pass it through
			// to draw_zoom for completeness but the simple implementation below
			// does not access the XImage internals (avoids C/gg ABI issues).
			img := renderer.cap.capture_region(x, y, w, h) or {
				logger.err('capture failed: ${err}')
				return
			}

			renderer.draw_zoom(img, w, h) or { logger.err('draw zoom failed: ${err}') }
		}
	)

	if renderer.gg == unsafe { nil } {
		return error('failed to create a new context')
	}

	logger.debug('renderer gg context user_data: ${renderer.gg.user_data}')
	logger.info('new gg context created succesfully')

	return renderer
}

// draw_zoom draws a zoomed version of the given XImage
// onto the gg window — diagnostic edition
pub fn (mut r GGRenderer) draw_zoom(ximg &C.XImage, w int, h int) ! {
	logger.debug('draw_zoom start function')
	r.gg.begin()

	r.gg.end()
	logger.debug('draw_zoom end function')
}
