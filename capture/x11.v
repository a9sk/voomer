module capture

import logger
import x11
// something to understand:
// when compiling i get the following error:
// capture/x11.v:4:8: warning: module 'x11' is imported but never used
// but if i try to remove the import everything fails lol

#flag -lX11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>

struct X11Capturer {
mut:
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
	// TODO: it might make sense to move the x11_open_display outside of the cap initialization
	logger.debug('initializing X11Capturer')
	mut cap := X11Capturer{
		display: x11_open_display() or { return error('${err}') }
		root:    0
		gc:      C.GC(0)
	}
	logger.debug('display ptr valid? ${cap.display != unsafe { nil }}')
	logger.debug('cap.display set correctly')

	cap.root = x11_default_root_window(cap.display) or { return error('${err}') }
	logger.debug('cap.root set correctly')

	// TODO: move to function
	// screen := C.XDefaultScreen(cap.display)
	// cap.gc = x11_default_gc(cap.display, screen) or { return error('${err}') }

	cap.gc = x11_create_gc(cap.display, cap.root) or { return error('${err}') }
	logger.debug('cap.gc set correctly')

	logger.info('X11Capturer created succesfully, returning now...')

	return cap
}

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

// x11_default_root_window uses C's XDefaultRootWindow to
// retrive the root window (the full screen)
// note: even if you switch vdesktop x11 draws it on the same root
// TODO: maybe it would be better to return a C.Window and not the u64 value
fn x11_default_root_window(display &C.Display) !C.Window {
	logger.debug('x11_default_root_window start function')
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Display_Functions
	// display specifies the connection to the X server.
	// Both (only one implementation here) return the root window for the default screen.
	// Window XDefaultRootWindow(Display *display);
	d := C.XDefaultRootWindow(display)
	if d == 0 {
		return error('failed to retrive X root window')
	}
	logger.info('X root window retrived succesfully: ' + u64(d).str())

	return d
}

// x11_create_gc uses C's XCreateGC to create a graphic
// contex and returns it to the caller
// note: this function is not used for now as it segfaults
// TODO: implement a working x11_create_cg function for pretty drawing
fn x11_create_gc(display &C.Display, root C.Window) !C.GC {
	logger.debug('x11_create_gc start function')
	logger.debug('display: ${display.str()}, root: ${root}')
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Display_Functions
	// To create a new GC that is usable on a given screen with a depth of drawable, use XCreateGC.
	// GC XCreateGC(Display *display, Drawable d, unsigned long valuemask, XGCValues *values);
	// The XCreateGC function creates a graphics context and returns a GC.
	// The GC can be used with any destination drawable having the same root
	// and depth as the specified drawable.
	// Use with other drawables results in a BadMatch error.
	// XCreateGC can generate BadAlloc, BadDrawable, BadFont, BadMatch, BadPixmap, and BadValue errors.
	d := C.XCreateGC(display, root, u64(0), unsafe { nil })
	// if d == C.GC(0) {
	//	return error('failed to create X graphic context')
	// }
	logger.info('X graphic context created succesfully')

	return d
}

// x11_default_gc uses C's XDefaultGC to retrive
// the default graphic context
fn x11_default_gc(display &C.Display, screen int) !C.GC {
	logger.debug('x11_default_gc start function')
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Display_Functions
	// Both (only one here) return the default screen
	// number referenced by the XOpenDisplay function.
	// This macro or function should be used to retrieve the screen number
	// in applications that will use only a single screen.
	// GC XDefaultGC(Display *display, int screen_number);
	d := C.XDefaultGC(display, screen)
	// if d == C.GC(0) {
	// 	return error('failed to retrive X default graphic context')
	// }
	logger.info('X default graphic context retrived succesfully')

	return d
}

// get_display_ptr_str returns the cap.display pointer casted to string
pub fn (cap X11Capturer) get_display_ptr_str() string {
	return cap.display.str()
}

//  TODO: document capture_region
pub fn (cap X11Capturer) capture_region(x int, y int, w int, h int) ![]u8 {
	logger.debug('capture_region start function')

	return error('not implemented yet!!!')
}

//  TODO: document clean_capturer
pub fn (cap X11Capturer) clean_capturer() !bool {
	logger.debug('clean_capturer start function')

	return error('not implemented yet!!!')
}
