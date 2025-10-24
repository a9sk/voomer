module capture

import logger
import x11
// something to understand:
// when compiling i get the following error:
// capture/x11.v:4:8: warning: module 'x11' is imported but never used
// but if i try to remove the import everything fails lol

struct X11Capturer {
pub mut:
	display &C.Display // the active connection to the X server
	root    C.Window   // the top-level window (the full screen)
	// gc      C.GC       // graphic context helper for drawing/copying
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
		// gc:      C.GC(0) // note: i am not using a graphic context for now
	}
	logger.debug('display ptr valid? ${cap.display != unsafe { nil }}')
	logger.debug('cap.display set correctly')

	cap.root = x11_default_root_window(cap.display) or { return error('${err}') }
	logger.debug('cap.root set correctly')

	// note: i am not using a graphic context for now, i will need it when i will be drawing
	//       to the window and stuff like that
	// this first version is only used for an initial implementation
	// screen := C.XDefaultScreen(cap.display)
	// cap.gc = x11_default_gc(cap.display, screen) or { return error('${err}') }
	// x11_create_gc should be the function used for th gc
	// cap.gc = x11_create_gc(cap.display, cap.root) or { return error('${err}') }
	// logger.debug('cap.gc set correctly')

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
	//  TODO: add error checks
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
	//  TODO: add error checks
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

// capture_region uses C's XGetImage to capture
// a specific region of the screen and returns it as a byte array
pub fn (cap X11Capturer) capture_region(x int, y int, w int, h int) !&C.XImage {
	logger.debug('capture_region start function')

	// ref:
	// The XGetImage function returns a pointer to an XImage structure.
	// This structure provides you with the contents of the specified rectangle
	// of the drawable in the format you specify. If the format argument is XYPixmap,
	// the image contains only the bit planes you passed to the plane_mask argument.
	// If the plane_mask argument only requests a subset of the planes of the display,
	// the depth of the returned image will be the number of planes requested.
	// If the format argument is ZPixmap, XGetImage returns as zero the bits
	// in all planes not specified in the plane_mask argument.
	// The function performs no range checking on the values in plane_mask
	// and ignores extraneous bits.
	// XGetImage returns the depth of the image to the depth member of the XImage structure.
	// The depth of the image is as specified when the drawable was created,
	// except when getting a subset of the planes in XYPixmap format,
	// when the depth is given by the number of bits set to 1 in plane_mask.
	// If the drawable is a pixmap, the given rectangle must be wholly contained
	// within the pixmap, or a BadMatch error results. If the drawable is a window,
	// the window must be viewable, and it must be the case that if there were no inferiors
	// or overlapping windows, the specified rectangle of the window would be fully
	// visible on the screen and wholly contained within the outside edges of the window,
	// or a BadMatch error results. Note that the borders of the window can be included
	// and read with this request. If the window has backing-store, the backing-store
	// contents are returned for regions of the window that are obscured by noninferior windows.
	// If the window does not have backing-store, the returned contents of such
	// obscured regions are undefined. The returned contents of visible regions of
	// inferiors of a different depth than the specified window's depth are also undefined.
	// The pointer cursor image is not included in the returned contents.
	// If a problem occurs, XGetImage returns NULL.
	// XGetImage can generate BadDrawable, BadMatch, and BadValue errors.
	// XImage *XGetImage(Display *display, Drawable d, int x, int y, unsigned int width, unsigned int height, unsigned long plane_mask, int format);
	d := C.XGetImage(cap.display, cap.root, u64(x), u64(y), u32(w), u32(h), u64(0xFFFFFFFF),
		2) // 2 is ZPixmap
	// note: for how the code is implemented right now, if the cursor is too close
	//       to the screen borders, the capture will fail
	// TODO: implement a way to capture regions close to the borders
	if d == unsafe { nil } {
		return error('failed to capture region x=${x}, y=${y}, w=${w}, h=${h}')
	}
	logger.debug('region captured succesfully: x=${x}, y=${y}, w=${w}, h=${h}')

	return d
}

//  TODO: document clean_capturer
pub fn (cap X11Capturer) clean_capturer() !bool {
	logger.debug('clean_capturer start function')

	return error('not implemented yet!!!')
}
