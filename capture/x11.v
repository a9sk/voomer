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

// Display *XOpenDisplay(char *display_name);
fn C.XOpenDisplay(display_name &char) &C.Display

// ----------------------------------

struct X11Capturer {
	display &C.Display // the active connection to the X server
	root    C.Window   // the top-level window (the full screen)
	gc      C.GC       // graphic context helper for drawing/copying
}

// new_x11_capturer initializes and returns an X11Capturer
// as defined in the X11Capturer struct, uses helper functions to
// interact with original C functions
pub fn new_x11_capturer() !X11Capturer {
	logger.debug('new_x11_capturer start function')

	// initialize to an empty instance of X11Capturer
	logger.debug('initializing X11Capturer')
	mut cap := X11Capturer{
		display: x11_open_display() or { return error('${err}') }
		root:    0
		gc:      C.GC(0)
	}
	logger.info('X11Capturer created succesfully, returning now...')

	return cap
}

// get_display_ptr_str returns the cap.display pointer casted to string
pub fn (cap &X11Capturer) get_display_ptr_str() string {
	return cap.display.str()
}

//  TODO: document clean_capturer
pub fn (cap X11Capturer) clean_capturer() !bool {
	logger.debug('clean_capturer start function')

	return error('not implemented yet!!!')
}
