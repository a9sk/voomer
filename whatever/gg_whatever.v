module render

import logger
import gg
import cursor
import capture
import time
import math

pub struct GGRenderer {
	cap &capture.X11Capturer // keep a pointer to the capturer
pub mut:
	gg &gg.Context // context used for rendering
}

// new_renderer uses gg's new_context function and
// returns a renderer (for now it is just a pointer to a gg.Context)
pub fn new_renderer(cap &capture.X11Capturer) !&GGRenderer {
	logger.debug('new_renderer start function')

	mut renderer := &GGRenderer{
		gg:  unsafe { nil }
		cap: cap
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

			// capture region around cursor
			x, y, w, h := cursor.get_cursor_with_pad(renderer.cap.display, renderer.cap.root) or {
				logger.err('get cursor failed: ${err}')
				return
			}

			// capture_region may return an XImage pointer; we pass it through
			// to draw_zoom for completeness but the simple implementation below
			// does not access the XImage internals (avoids C/gg ABI issues).
			img := renderer.cap.capture_region(x, y, w, h) or {
				logger.err('capture failed: ${err}')
				return
			}

			renderer.draw_zoom(img, w, h) or { logger.err('draw zoom failed: ${err}') }
		}
	)

	if renderer.gg == unsafe { nil } {
		return error('failed to create a new context')
	}

	logger.debug('renderer gg context user_data: ${renderer.gg.user_data}')
	logger.info('new gg context created succesfully')

	return renderer
}

// draw_zoom draws a zoomed version of the given XImage
// onto the gg window — diagnostic edition
pub fn (mut r GGRenderer) draw_zoom(ximg &C.XImage, w int, h int) ! {
	logger.debug('draw_zoom start function')
	r.gg.begin()

	win_w := r.gg.width
	win_h := r.gg.height

	// background so diagnostics are visible
	r.gg.draw_rect_filled(0, 0, f32(win_w), f32(win_h), gg.Color{ r: 6, g: 6, b: 6 })

	// quick sanity
	if ximg == unsafe { nil } {
		logger.err('draw_zoom: ximg is nil')
		// big obvious error box
		r.gg.draw_rect_filled(10, 10, f32(win_w - 20), f32(win_h - 20), gg.Color{
			r: 200
			g: 40
			b: 40
		})
		r.gg.end()
		return
	}
	if w <= 0 || h <= 0 {
		logger.err('draw_zoom: invalid capture size w=${w} h=${h}')
		r.gg.end()
		return
	}

	// CONFIG toggles
	swap_rb := false // try `true` if colors look wrong (blue <-> red)
	show_sample_area := true // draw the actual pixels (small area)
	sample_size := 120 // how many pixels from capture to draw (per side) - keep small for speed

	// Sample a handful of pixels and log them (center + corners)
	unsafe {
		center_x := w / 2
		center_y := h / 2
		cvals := [
			C.XGetPixel(ximg, int(center_x), int(center_y)),
			C.XGetPixel(ximg, int(0), int(0)),
			C.XGetPixel(ximg, int(w - 1), int(0)),
			C.XGetPixel(ximg, int(0), int(h - 1)),
			C.XGetPixel(ximg, int(w - 1), int(h - 1)),
		]
		for i, pv in cvals {
			v := u64(pv)
			rb := u8((v >> 16) & 0xFF)
			gb := u8((v >> 8) & 0xFF)
			bb := u8(v & 0xFF)
			logger.debug('sample[${i}] raw=0x${v:x} r=${rb} g=${gb} b=${bb}')
		}

		// If center pixel is zero-ish, log and show big red indicator
		if u64(cvals[0]) == 0 {
			logger.err('capture looks empty (center pixel == 0). This suggests XGetImage returned blank data or format mismatch.')
			// big magenta box to show failure clearly
			r.gg.draw_rect_filled(20, 20, f32(win_w - 40), f32(win_h - 40), gg.Color{
				r: 255
				g: 0
				b: 255
			})
			// small text-like indicator using rectangles
			r.gg.draw_rect_filled(30, 30, 200, 28, gg.Color{ r: 0, g: 0, b: 0 })
			r.gg.draw_rect_filled(34, 34, 192, 20, gg.Color{ r: 255, g: 255, b: 255 })
			r.gg.end()
			return
		}

		// Draw a scaled sample area from the captured image so you can verify pixels visually.
		if show_sample_area {
			// clamp sample box to capture size
			sw := if sample_size < w { sample_size } else { w }
			sh := if sample_size < h { sample_size } else { h }

			// Destination area: keep it centered and reasonably large
			dst_w := if win_w < 600 { win_w - 40 } else { 600 }
			dst_h := if win_h < 400 { win_h - 40 } else { 400 }
			dst_x := (win_w - dst_w) / 2
			dst_y := (win_h - dst_h) / 2

			// scale factors (float)
			sx := f32(dst_w) / f32(sw)
			sy := f32(dst_h) / f32(sh)

			// For each source pixel in the sample area draw a small rect scaled to destination
			for sy_i in 0 .. sh {
				for sx_i in 0 .. sw {
					pv := C.XGetPixel(ximg, int(sx_i), int(sy_i))
					val := u64(pv)
					rb := u8((val >> 16) & 0xFF)
					gb := u8((val >> 8) & 0xFF)
					bb := u8(val & 0xFF)
					if swap_rb {
						tmp := rb
						rb = bb
						bb = tmp
					}
					col := gg.Color{
						r: rb
						g: gb
						b: bb
					}
					dx := dst_x + int(f32(sx_i) * sx)
					dy := dst_y + int(f32(sy_i) * sy)
					// draw one pixel block (clamped)
					r.gg.draw_rect_filled(dx, dy, f32(sx) + 0.5, f32(sy) + 0.5, col)
				}
			}

			// border around sample
			r.gg.draw_rect_filled(dst_x - 2, dst_y - 2, f32(dst_w + 4), f32(dst_h + 4),
				gg.Color{ r: 200, g: 200, b: 200 })
		}
	}
	// keep CPU sane while debugging
	time.sleep(33 * time.millisecond)
	r.gg.end()
	logger.debug('draw_zoom end function')
}
