module render

import logger
import gg
import x11

struct GGRenderer {
mut:
	gg &gg.Context // context
}

// new_renderer uses gg's new_context function and
// returns a renderer (for now it is just a pointer to a gg.Context)
pub fn new_renderer() !GGRenderer {
	logger.debug('new_renderer start function')
	// ref: https://github.com/vlang/v/blob/master/vlib/gg
	// fn new_context(cfg Config) &Context
	// new_context returns an initialized Context allocated on the heap.
	renderer := GGRenderer{
		gg: gg.new_context(width: 800, height: 600, create_window: true, window_title: 'Zoom')
	}
	if renderer.gg == unsafe { nil } {
		return error('failed to create a new context')
	}
	logger.info('new gg context created succesfully')

	return renderer
}

pub fn (mut r GGRenderer) draw_zoom(img &C.XImage, w int, h int) {
	r.gg.begin()
	// TODO: convert raw data to gg.Image, draw scaled
	r.gg.end()
}
