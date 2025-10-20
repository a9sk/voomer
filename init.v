module main

fn init_x11() {
	debug('initializing x11 backend')
}

fn init_wayland() {
	lerr('wayland not supported yet')
	exit(1)
}
