module main

import os
import logger

// find_session is un util that finds the session (lol)
// uses env variables to find out if it is x11 or wayland
fn find_session() ?string {
	logger.debug('find_session')

	// find session follows this bash code:
	//
	// case $((0${DISPLAY:+1} | 0${WAYLAND_DISPLAY:+2})) in
	//    1) echo "X11" ;;
	//    2) echo "Wayland" ;;
	//    3) echo "XWayland" ;;
	//    *) echo "Unknown" ;;
	// esac

	session_type := os.getenv('XDG_SESSION_TYPE')
	wayland_display := os.getenv('WAYLAND_DISPLAY')
	display := os.getenv('DISPLAY')

	//  TODO: check if this actually works on non x11 systems
	if session_type == 'wayland' || wayland_display != '' {
		return 'wayland'
	} else if session_type == 'x11' || display != '' {
		return 'x11'
	} else {
		return none
	}
}
