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

// ----------------------------------
