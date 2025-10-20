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
	info('application started')
}

fn debug(s string) {
	logger.log(logger.Level.debug, s)
}

fn info(s string) {
	logger.log(logger.Level.info, s)
}

fn err(s string) {
	logger.log(logger.Level.err, s)
}
