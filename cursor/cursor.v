module cursor

import logger
import x11

// get_cursor_with_pad uses C's XQueryPointer and returns the cursor's
// position with a padding of some pixels around it (x, y, w, h)
pub fn get_cursor_with_pad(display &C.Display, root C.Window) !(int, int, int, int) {
	logger.debug('get_cursor_with_pad start function')

	mut root_return := C.Window(0)
	mut child_return := C.Window(0)
	mut root_x := 0
	mut root_y := 0
	mut win_x := 0
	mut win_y := 0
	mut mask_return := u32(0)

	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#XQueryPointer
	// The XQueryPointer function returns the root window the pointer is logically on and
	// the pointer coordinates relative to the root window's origin.
	// If XQueryPointer returns False, the pointer is not on the same screen as the specified window,
	// and XQueryPointer returns None to child_return and zero to win_x_return and win_y_return.
	// If XQueryPointer returns True, the pointer coordinates returned to win_x_return and
	// win_y_return are relative to the origin of the specified window.
	// In this case, XQueryPointer returns the child that contains the pointer, if any,
	// or else None to child_return.
	// XQueryPointer returns the current logical state of the keyboard buttons and the
	// modifier keys in mask_return. It sets mask_return to the bitwise inclusive OR of one
	// or more of the button or modifier key bitmasks to match the current state of
	// the mouse buttons and the modifier keys.
	// XQueryPointer can generate a BadWindow error.
	// Bool XQueryPointer(Display *display, Window w, Window *root_return, Window *child_return, int *root_x_return, int *root_y_return, int *win_x_return, int *win_y_return, unsigned int *mask_return);
	d := C.XQueryPointer(display, root, &root_return, &child_return, &root_x, &root_y,
		&win_x, &win_y, &mask_return)
	if d == 0 {
		return error('failed to get cursor position')
	}

	return int(root_x), int(root_y), 200, 200
}
