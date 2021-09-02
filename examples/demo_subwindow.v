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
	color  gx.Color   = gx.blue
}

fn main() {
	mut app := &App{}
	rect := ui.rectangle(color: gx.red)
	mut window := ui.window(
		width: win_width
		height: win_height
		title: 'Resizable Window'
		resizable: true
		state: app
		children: [
			ui.row(
				id: 'row'
				margin_: .3
				widths: .2
				heights: .4
				bg_color: gx.rgba(180, 100, 140, 255)
				children: [
					ui.button(text: 'Add user', bg_color: &app.color, onclick: btn_click),
					ui.row(
						children: [
							rect,
							uic.button_color(
								id: 'btn_col'
								bg_color: &rect.color
							),
						]
					),
				]
			),
		]
	)
	// This add a unique colorbox
	uic.colorbox_add(mut window)
	// uic.colorbox_add(mut window)
	app.window = window
	ui.run(window)
}

fn btn_click(a voidptr, b &ui.Button) {
	rect := b.ui.window.stack('row')
	// connect the colorbox to the rect_bg_color
	uic.colorbox_connect(b.ui.window, &rect.bg_color)
}
