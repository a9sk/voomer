module render

import logger
import gg
import x11
import cursor
import time
import capture

pub struct GGRenderer {
	cap &capture.X11Capturer // keep a pointer to the capturer
pub mut:
	gg       &gg.Context // context used for rendering
	image    &gg.Image   // image used for rendering
	rgba_buf []u8        // buffer so we don't allocate each frame
}

// new_renderer uses gg's new_context function and
// returns a renderer (for now it is just a pointer to a gg.Context)
pub fn new_renderer(cap &capture.X11Capturer) !&GGRenderer {
	logger.debug('new_renderer start function')

	mut renderer := &GGRenderer{
		gg:    unsafe { nil }
		cap:   cap
		image: unsafe { nil }
	}

	// ref: https://github.com/vlang/v/blob/master/vlib/gg
	// fn new_context(cfg Config) &Context
	// new_context returns an initialized Context allocated on the heap.
	renderer.gg = gg.new_context(
		width:         800
		height:        600
		create_window: true
		window_title:  'voomer'
		frame_fn:      fn [mut renderer] (mut ctx gg.Context) {
			if renderer == unsafe { nil } {
				logger.err('renderer is nil in frame')
				return
			}

			x, y, w, h := cursor.get_cursor_with_pad(renderer.cap.display, renderer.cap.root) or {
				logger.err('get cursor failed: ${err}')
				return
			}

			img := renderer.cap.capture_region(x, y, w, h) or {
				logger.err('capture failed: ${err}')
				return
			}

			renderer.draw_zoom(img, w, h) or { logger.err('draw zoom failed: ${err}') }
		}
		// user_data:     voidptr(renderer)
	)

	if renderer.gg == unsafe { nil } {
		return error('failed to create a new context')
	}

	logger.debug('renderer gg context user_data: ${renderer.gg.user_data}')
	logger.info('new gg context created succesfully')

	return renderer
}

// draw_zoom draws a zoomed version of the given XImage
// onto the gg window
pub fn (mut r GGRenderer) draw_zoom(ximg &C.XImage, w int, h int) ! {
	logger.debug('draw_zoom start function')
	// ref: https://modules.vlang.io/gg.html
	// gg.Context fn begin()
	// begin prepares the context for drawing.
	// All drawing functions should be called between begin and end.

	required := w * h * 4
	if r.rgba_buf.len < required {
		r.rgba_buf = []u8{len: required} // preallocate exact size
	}

	ximage_to_bytes_into(ximg, w, h, mut r.rgba_buf) or {
		return error('ximage convert failed: ${err}')
	}

	r.gg.begin()

	// note: gg APIs vary across versions.
	//       i absolutely hate this inconsistency.
	//       i also absolutely hate the lack of proper documentation.
	//       i also absolutely hate this language.
	if r.image == unsafe { nil } {
		draw_rgba_as_blocks(mut r, w, h)
	} else {
		unsafe {
			r.image.update_pixel_data(r.rgba_buf.data)
		}
		// ref: https://modules.vlang.io/gg.html
		// gg.Context fn draw_image(x int, y int, img &Image)
		// draw_image draws the given image at position (x, y).
		// r.gg.draw_image(0, 0, r.gg.new_image_from_memory(img, w, h))
		r.gg.draw_image(0, 0, f32(w), f32(h), r.image)
	}

	r.gg.end()

	logger.debug('draw_zoom end function')
}

// TODO: document all functions after this comment

// ximage_to_bytes_into converts an XImage to a byte array in RGBA format
fn ximage_to_bytes_into(ximg &C.XImage, w int, h int, mut out []u8) ! {
	if ximg == unsafe { nil } {
		return error('XImage is nil')
	}
	if out.len < w * h * 4 {
		return error('output buffer too small')
	}

	bpp := int(ximg.bits_per_pixel)
	bytes_per_line := int(ximg.bytes_per_line)
	red_mask := u64(ximg.red_mask)
	green_mask := u64(ximg.green_mask)
	blue_mask := u64(ximg.blue_mask)

	if bpp == 32 && bytes_per_line >= w * 4 && red_mask != 0 && green_mask != 0 && blue_mask != 0 {
		unsafe {
			src := byteptr(ximg.data)
			for yy in 0 .. h {
				row_src := src + yy * bytes_per_line
				dst_row_idx := yy * w * 4
				for xx in 0 .. w {
					b0 := u32(row_src[xx * 4 + 0])
					b1 := u32(row_src[xx * 4 + 1])
					b2 := u32(row_src[xx * 4 + 2])
					b3 := u32(row_src[xx * 4 + 3])
					pixel := b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
					rch := u8((u64(pixel) & red_mask) >> mask_to_shift_u64(red_mask))
					gch := u8((u64(pixel) & green_mask) >> mask_to_shift_u64(green_mask))
					bch := u8((u64(pixel) & blue_mask) >> mask_to_shift_u64(blue_mask))
					dst := dst_row_idx + xx * 4
					out[dst + 0] = rch
					out[dst + 1] = gch
					out[dst + 2] = bch
					out[dst + 3] = 255
				}
			}
		}
		return
	}

	unsafe {
		for py in 0 .. h {
			for px in 0 .. w {
				p := C.XGetPixel(ximg, C.int(px), C.int(py))
				val := u64(p)
				rch := u8((val >> 16) & 0xFF)
				gch := u8((val >> 8) & 0xFF)
				bch := u8(val & 0xFF)
				ach := u8((val >> 24) & 0xFF)
				idx := (py * w + px) * 4
				out[idx + 0] = rch
				out[idx + 1] = gch
				out[idx + 2] = bch
				out[idx + 3] = ach
			}
		}
	}
}

fn mask_to_shift_u64(mask u64) int {
	if mask == 0 {
		return 0
	}
	mut m := mask
	mut shift := 0
	for (m & 1) == 0 {
		m >>= 1
		shift++
	}
	return shift
}

fn draw_rgba_as_blocks(mut r GGRenderer, w int, h int) {
	win_w := r.gg.width
	win_h := r.gg.height
	zoom := 2
	block := zoom
	tw := w * block
	th := h * block
	start_x := (win_w - tw) / 2
	start_y := (win_h - th) / 2

	r.gg.draw_rect_filled(0, 0, f32(win_w), f32(win_h), gg.Color{ r: 10, g: 10, b: 10 })

	idx := 0
	for py in 0 .. h {
		for px in 0 .. w {
			if idx + 3 >= r.rgba_buf.len {
				break
			}
			rb := r.rgba_buf[idx]
			gb := r.rgba_buf[idx + 1]
			bb := r.rgba_buf[idx + 2]
			ab := r.rgba_buf[idx + 3]
			idx += 4
			if ab == 0 {
				continue
			}
			color := gg.Color{
				r: rb
				g: gb
				b: bb
			}
			xpos := start_x + px * block
			ypos := start_y + py * block
			r.gg.draw_rect_filled(xpos, ypos, f32(block), f32(block), color)
		}
	}
}
