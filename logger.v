module logger

import time

pub enum Level {
	none
	debug
	info
	err
}

pub fn log(l Level, s string) {
	// print('called: logger')
	match l {
		.debug { println(get_time() + ' [DEBUG]:  ' + s) }
		.info { println(get_time() + ' [INFO]:   ' + s) }
		.err { println(get_time() + ' [ERROR]:  ' + s) }
		else { println('no method :' + l.str() + ' ') }
	}
}

fn get_time() string {
	return time.now().str()
}
