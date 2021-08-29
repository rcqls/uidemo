import ui
import uicomponent as uic

import gx

const (
	win_width  = 800
	win_height = 600
)

struct App {
mut:
	window &ui.Window = 0
}

fn main() {
	mut app := &App{}
	window := ui.window(
		width: win_width
		height: win_height
		title: 'Resizable Window'
		resizable: true
		state: app
		children: [
			ui.row(
				id: "row"
				margin_: .3
				widths: .4
				heights: .4
				bg_color: gx.rgba(180, 100, 140, 255)
				children: [
					ui.button(text: 'Add user', onclick: btn_click),
				]
			),
			ui.subwindow(
				id: "sw"
				x: 0, y: 0
				layout: uic.colorbox(id: 'cbox', light: true, hsl: false)
			)
		]
	)
	app.window = window
	ui.run(window)
}

fn btn_click(a voidptr, b &ui.Button) {
	mut s := b.ui.window.subwindow("sw")
	cb_layout := b.ui.window.stack("cbox")
	mut cb := uic.component_colorbox(cb_layout)
	rect := b.ui.window.stack("row")
	cb.connect(&rect.bg_color)
	s.set_visible(s.hidden)
	// ui.message_box('Built with V UI')
	// b.ui.window.message('Built with V UI\nThus \nAnd')
}