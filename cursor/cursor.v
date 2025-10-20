module cursor

import logger

pub fn get_cursor_with_pad() !(int, int, int, int) {
	logger.debug('get_cursor_with_pad start function')

	return 100, 100, 200, 200
}
