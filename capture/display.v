module capture

import logger

// x11_open_display uses C's XOpenDisplay to open
// a connection to the X display and returns a pointer to it
fn x11_open_display() !&C.Display {
	logger.debug('x11_open_display start function')
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Display_Functions
	// To open a connection to the X server that controls a display, use XOpenDisplay.
	// Display *XOpenDisplay(char *display_name);
	d := C.XOpenDisplay(unsafe { nil })
	if d == unsafe { nil } {
		return error('failed to open X display')
	}
	logger.info('X display opened succesfully')

	return d
}
