module x11

import logger

// we need to implement a way to simply catch X11 errors and log the error
// there is no need to keep track of them, just log them
// see https://tronche.com/gui/x/xlib/events/handling-errors.html

fn x11_error_handler(display &C.Display, error_event &C.XErrorEvent) int {
	mut buf := []u8{len: 256, init: 0}
	unsafe {
		C.XGetErrorText(display, int(error_event.error_code), &char(buf.data), buf.len)
	}
	err_msg := unsafe { cstring_to_vstring(&buf[0]) }
	logger.debug('handling X11 error...')
	logger.err('X11 Error: ${err_msg}')
	return 0
}

pub fn set_x11_error_handler() {
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
