// voomer -- v0.0.0 -- zooming utility written in v
//
//   Simple utility to zoom on the screen following cursor,
//   used as a way to learn v language.
//   Copyright (c) 2025, Emiliano Rizzonelli
//
// More info: https://github.com/vlang/v

module main

import logger

fn main() {
	logger.info('application started')

	// uses compile time code compilation for smaller output files
	// os detection is builtin (linux/windows/macos)
	$if linux {
		// very neat thing this of having or {} on null return
		session := find_session() or {
			logger.err('unsupported linux display')
			exit(1)
		}

		// we use normal if-else instead of $if-$else since session
		// is unknow at compile time (obviously)
		if session == 'x11' {
			logger.debug('using X11 backend')
			init_x11()
		} else if session == 'wayland' {
			logger.debug('using wayland backend')
			init_wayland()
		}
		// we do not need an else as find_session() only returns if
		// i3 or wayland and exits otherwise
	} $else $if windows {
		logger.err('windows not supported yet')
		exit(1)
	} $else $if macos {
		logger.err('mac os not supported yet')
		exit(1)
	} $else {
		logger.err('os not supported yet')
		exit(1)
	}

	exit(0)
}
