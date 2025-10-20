module capture

import logger

#flag -lX11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>

// ----------------------------------
// declare these to satisfy v's parser

@[typedef]
struct C.Display {}

@[typedef]
struct C.GC {}

type C.Window = u64

// ----------------------------------

struct X11Capturer {
	display &C.Display
	root    C.Window
	gc      C.GC
}

pub fn new_x11_capturer() !X11Capturer {
	logger.debug('new_x11_capturer start function')

	return error('not implemented yet!!!')
}

pub fn (cap X11Capturer) capture_region(x int, y int, w int, h int) ![]u8 {
	logger.debug('capture_region start function')

	return error('not implemented yet!!!')
}
