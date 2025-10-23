module render

import logger
// import x11

// NOTE: this gl implementation is NOT working, it is also NOT work in progress,
//       i just started uni and have a few projects/other things going on right now
//       and i really cannot spend this much time on understanding some (in my opninon)
//       very difficult and unprecise documentation. This project is done without help
//       from ai agents and stuff like that and in order to keep things this way
//       i will avoid this version of the rendering process for now.

// ROADMAP
//
// if anyone will ever see this code, this are the steps that i belive should be followed
// to implement the functionality
//
// 1. with glXChooseVisual we choose an XVisualInfo struct describing what visual supports OpenGL,
// we put it in ren.visual
// 2.with XCreateColormap we create a new colormap since the chosen visual might not mach the default
// screen's colormap
// 3. with XCreateWindow we create a brand new X11 window in which OpenGL can draw
// note: for a first implementation we can use XCreateSimpleWindow as well and skip the visual/colormap parts
// 4. with XMapWindow we can map the event masks (expose, keypress etc) to the window
// 5. with glXCreateContext we make a new rendering context
// 6. with glxMakeCurrent we tell OpenGL to draw in the created window when gl functions are called
//
// for any question check out the References section i put in the README
// for doubts on my implementation feel free to contact me at emiliano.rizzonelli@proton.me

struct GLXWindow {
mut:
	visual   &C.XVisualInfo // the kind of visual that can be used to create OpenGL window
	colormap C.Colormap     // the colormap (avoid mismatch with default)
	window   C.Window       // the window OpenGL can draw on
	context  voidptr        // state machine for OpenGL to remember current program etc...
}

// init_gl_window initialized and returns an XGL window
// which can be written and drawn on by OpenGL
pub fn init_gl_window(display &C.Display) ! {
	logger.debug('init_gl_window start function')

	logger.debug('initializing GLXWindow')
	mut ren := GLXWindow{
		visual:   glx_choose_visual(display) or { return error('${err}') }
		colormap: C.Colormap{}
		window:   0
		context:  unsafe { nil }
	}

	logger.debug(ren.window.str())
}

// glx_choose_visual uses C's glXChooseVisual to pick
// a valid glx visual based on the display
// TODO: implement this same functionality using glXChooseFBConfig
fn glx_choose_visual(display &C.Display) !&C.XVisualInfo {
	logger.debug('glx_choose_visual start function')

	attributes := [C.GLX_RGBA, C.GLX_DOUBLEBUFFER, C.GLX_RED_SIZE, 8, C.GLX_GREEN_SIZE, 8,
		C.GLX_BLUE_SIZE, 8, C.GLX_ALPHA_SIZE, 8, C.None]
	screen := x11_default_screen_of_display(display) or { return error('${err}') }
	// ref: https://www.gnu.org/software/guile-opengl/manual/html_node/Low_002dLevel-GLX.html#Low_002dLevel-GLX
	// glXChooseVisual seems to be deprecated (https://metacpan.org/pod/X11::GLX#glXChooseVisual),
	// it is tho more stable and we can close an eye for now
	// TODO: come back to this functionlity and understand why it fails
	// XVisualInfo glXChooseVisual($display, $screen, \@attributes);
	// note: screen and attributes are optional in the call
	d := C.glXChooseVisual(display, screen, &attributes[0])
	if d == unsafe { nil } {
		return error('failed to find a valid visual')
	}
	logger.info('glx visual chosen succesfully')

	return d
}

// x11_default_screen_of_display uses C's XDefaultScreenOfDisplay
// to retrive the int id for the current display default screen
fn x11_default_screen_of_display(display &C.Display) !&C.Screen {
	logger.debug('x11_default_screen_of_display start function')
	// ref: https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Overview_of_the_X_Window_System
	// Screen *XDefaultScreenOfDisplay(Display *display);
	// Both (only one here) return a pointer to the default screen.
	d := C.XDefaultScreenOfDisplay(display)
	if d == 0 {
		return error('failed to get the default screen')
	}
	logger.info('X screen retrived succesfully: ' + u64(d).str())

	return d
}
