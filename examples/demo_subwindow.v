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
	mut window := ui.window(
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
		]
	)
	// This add a unique colorbox
	uic.colorbox_add(mut window)
	app.window = window
	ui.run(window)
}

fn btn_click(a voidptr, b &ui.Button) {
	rect := b.ui.window.stack("row")
	// connect the colorbox to the rect_bg_color
	uic.colorbox_connect(b.ui.window, &rect.bg_color, 400, 300)
}