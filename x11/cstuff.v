module x11

// this file defines all of the c structs, c types and c functions

#flag -lX11
// #flag -lGL
// #flag -lGLX

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>
// #include <GL/glx.h>

// ----------------------------------
// types and functions used by the capture module

@[typedef]
pub struct C.Display {}

@[typedef]
pub struct C.GC {}

pub type C.ulong = u64
pub type C.size_t = usize

@[typedef]
pub struct C.XImage {
pub:
	width            C.int
	height           C.int
	xoffset          C.int
	format           C.int
	data             &u8 // char *data
	byte_order       C.int
	bitmap_unit      C.int
	bitmap_bit_order C.int
	bitmap_pad       C.int
	depth            C.int
	bytes_per_line   C.int
	bits_per_pixel   C.int
	red_mask         C.ulong
	green_mask       C.ulong
	blue_mask        C.ulong
}

pub type C.Window = u64

pub type C.int = int

// Display *XOpenDisplay(char *display_name);
pub fn C.XOpenDisplay(display_name &char) &C.Display

// Window XDefaultRootWindow(Display *display);
pub fn C.XDefaultRootWindow(display &C.Display) C.Window

// GC XCreateGC(Display *display, Drawable d, unsigned long valuemask, XGCValues *values);
pub fn C.XCreateGC(display &C.Display, d C.Window, valuemask u64, values voidptr) C.GC

// int XDefaultScreen(Display *display);
pub fn C.XDefaultScreen(display &C.Display) int

// GC XDefaultGC(Display *display, int screen_number);
pub fn C.XDefaultGC(display &C.Display, screen int) C.GC

// XImage *XGetImage(Display *display, Drawable d, int x, int y, unsigned int width, unsigned int height, unsigned long plane_mask, int format);
pub fn C.XGetImage(display &C.Display, d C.Window, x C.int, y C.int, width u32, height u32, plane_mask u64, format C.int) &C.XImage

// ----------------------------------

// ----------------------------------
// types and functions used by the render module

@[typedef]
pub struct C.XVisualInfo {}

// TODO: what should go here???
@[typedef]
pub struct C.Colormap {}

pub type C.Screen = u64

// this type is commented since it is defined earlier in this file
// pub type C.Window = u64

// XVisualInfo *glXChooseVisual($display, $screen, \@attributes);
pub fn C.glXChooseVisual(display &C.Display, C.int, &C.int) &C.XVisualInfo

// Screen *XDefaultScreenOfDisplay(Display *display);
pub fn C.XDefaultScreenOfDisplay(display &C.Display) &C.Screen

// unsigned long XGetPixel(XImage *ximage, int x, int y);
pub fn C.XGetPixel(ximg &C.XImage, x C.int, y C.int) C.ulong

// *memcpy(void *dest, const void *src, size_t n);
pub fn C.memcpy(dest voidptr, src voidptr, n C.size_t) voidptr

// ----------------------------------

// ----------------------------------
// types and functions used by the cursor module

type C.uint = u32

type C.Bool = int

// Bool XQueryPointer(Display *display, Window w, Window *root_return, Window *child_return, int *root_x_return, int *root_y_return, int *win_x_return, int *win_y_return, unsigned int *mask_return);
pub fn C.XQueryPointer(display &C.Display, w &C.Window, root_return &C.Window, child_return &C.Window, root_x_return &C.int, root_y_return &C.int, win_x_return &C.int, win_y_return &C.int, mask_return &u32) C.Bool

// ----------------------------------

// ----------------------------------
// error codes

// BadMatch error code
pub const bad_match = 8

// XGetErrorText(Display *display, int code, char *buffer_return, int length);
pub fn C.XGetErrorText(display &C.Display, code C.int, buffer_return &char, length C.int)

// ----------------------------------

// ----------------------------------
// X11 error handling

@[typedef]
pub struct C.XErrorEvent {
pub:
	display      &C.Display
	resourceid   u64
	serial       u64
	error_code   u8
	request_code u8
	minor_code   u8
}

// XSetErrorHandler(int (*handler)(Display *, XErrorEvent *));
pub fn C.XSetErrorHandler(handler fn (&C.Display, &C.XErrorEvent) C.int) ?

// ----------------------------------
