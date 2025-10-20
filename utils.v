module main

import os

fn find_session() ?string {
	debug('find_session')

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

	if session_type == 'wayland' || wayland_display != '' {
		return 'wayland'
	} else if session_type == 'x11' || display != '' {
		return 'x11'
	} else {
		return none
	}
}
