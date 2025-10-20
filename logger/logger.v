module logger

import time

enum Level {
	none
	debug
	info
	err
}

fn log(l Level, s string) {
	// print('called: logger')
	match l {
		//  TODO: implement a base level to avoid debugs in prod
		.debug { println(get_time() + ' [DEBUG]:  ' + s) }
		.info { println(get_time() + ' [INFO]:   ' + s) }
		.err { println(get_time() + ' [ERROR]:  ' + s) }
		else { println('no method :' + l.str() + ' ') }
	}
}

pub fn debug(s string) {
	log(Level.debug, s)
}

pub fn info(s string) {
	log(Level.info, s)
}

pub fn err(s string) {
	log(Level.err, s)
}

fn get_time() string {
	return time.now().str()
}
