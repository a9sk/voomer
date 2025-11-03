module x11

import logger

// we need to implement a way to simply catch X11 errors and log the error
// there is no need to keep track of them, just log them
// see https://tronche.com/gui/x/xlib/events/handling-errors.html

// x11_error_handler is the error handler function for X11 errors
fn x11_error_handler(display &C.Display, error_event &C.XErrorEvent) int {
	mut buf := []u8{len: 256, init: 0}
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#XGetErrorText
	// The XGetErrorText function returns a textual description of the specified error code.
	// It copies up to length - 1 characters of the description into the
	// buffer pointed to by buffer_return, null-terminating the string.
	// XGetErrorText can generate BadValue errors.
	// XGetErrorText(Display *display, int code, char *buffer_return, int length);
	unsafe {
		C.XGetErrorText(display, int(error_event.error_code), &char(buf.data), buf.len)
	}
	err_msg := unsafe { cstring_to_vstring(&buf[0]) }
	logger.debug('handling X11 error...')
	logger.err('X11 Error: ${err_msg}')
	return 0
}

pub fn set_x11_error_handler() {
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#XSetErrorHandler
	// The XSetErrorHandler function sets the error handler to the specified function
	// and returns the previous error handler.
	// The error handler is called when an error occurs.
	// XSetErrorHandler(int (*handler)(Display *, XErrorEvent *));
	_ := C.XSetErrorHandler(x11_error_handler)
}

pub fn cstring_to_vstring(cstr &u8) string {
	unsafe {
		mut len := 0
		for cstr[len] != 0 {
			len++
		}
		return tos(cstr, len)
	}
}
